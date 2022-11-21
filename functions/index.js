const functions = require("firebase-functions");
const admin = require('firebase-admin');
const spawn = require('child-process-promise').spawn;
const path = require('path');
const os = require('os');
const fs = require('fs');
const crypto = require('crypto');
const ntc = require('ntc');

const secrets = require('./secrets');

admin.initializeApp();
const db = admin.firestore();

const region = 'europe-west1';

exports.onNewUserCreate = functions.region(region).auth.user().onCreate(async (user) => {
    await admin.firestore().collection('users').doc(user.uid).set({email: user.email});
    await createNewWardrobe(user.uid, 'My Wardrobe')
});

exports.updateFollowingUser = functions.region(region).firestore.document('users/{userId}').onWrite((change, context) => {
    const followingKey = 'following'
    const followerKey = 'follower'
    const followingBefore = new Set(change.before.data()[[followingKey]]);
    const followingAfter = new Set(change.after.data()[[followingKey]]);
    const all = new Set([...followingBefore, ...followingAfter]);
    const newFollow = new Set();
    const unfollow = new Set();

    Array.from(all).every(element => {
        const hasBefore = followingBefore.has(element);
        const hasAfter = followingAfter.has(element);
        if (!hasBefore && hasAfter) { // New following
            newFollow.add(element);
        } else if (hasBefore && !hasAfter) { // Unfollowing
            unfollow.add(element);
        }
    });

    if (newFollow.size == 0 && unfollow.size == 0) {
        return;
    }

    Array.from(newFollow).every(element => {
        updateStringList(db.collection('users').doc(element), followerKey, context.params.userId, false)
    })

    Array.from(unfollow).every(element => {
        updateStringList(db.collection('users').doc(element), followerKey, context.params.userId, true)
    })
})

async function updateStringList(ref, key, value, willRemove) {
    await db.runTransaction(async (t) => {
        return t.get(ref).then(doc => {
            if (!doc.data()[key]) {
                if (willRemove) {
                    t.update(ref, {
                        [key]: []
                    });
                } else {
                    t.update(ref, {
                        [key]: [value]
                    });
                }
            } else {
                const followers = new Set(doc.data()[key]);
                if (willRemove) {
                    followers.delete(value);
                } else {
                    followers.add(value);
                }
                t.update(ref, { [key]: Array.from(followers) });
            }
        });
    });
}

exports.updateColorName = functions.region(region).firestore.document('items/{itemId}').onWrite((change, context) => {
    const colorNameKey = 'color_name'
    const colorHexKey = 'color_hex'
    const colorHexBefore = change.before.data()[[colorHexKey]];
    const colorHex = change.after.data()[[colorHexKey]];
    const colorNameBefore = change.before.data()[[colorNameKey]];
    const colorName = change.after.data()[[colorNameKey]];
    if (colorName == colorNameBefore && colorHex == colorHexBefore) {
        return;
    }
    let name
    if (colorHex != undefined) {
        name = ntc.name(colorHex)[1];
    }
    if (name == undefined || name.includes('Invalid Color')) {
        change.after.ref.update({[colorNameKey]: admin.firestore.FieldValue.delete()});
    } else {
        change.after.ref.update({[colorNameKey]: name});
    }
});

exports.followUser = functions.region(region).https.onRequest(async (req, res) => {
    const uid = req.headers['uid'];
    if (!await checkIsValidMethod(uid, req.headers['security_key'], req.headers['email'])) {
        res.status(401).send({'message': 'Unauthorized'});
        return;
    }
    const body = JSON.parse(req.body);
    // Begin function

    const followingUserId = body.followingUserId;
    const willRemove = body.willRemove;
    const userRef = db.collection('users').doc(uid)
    await updateStringList(userRef, 'following', followingUserId, willRemove)
    res.status(200).send({val: true})
});

exports.existUsername = functions.region(region).https.onRequest(async (req, res) => {
    const uid = req.headers['uid'];
    console.log('uid: ' + uid);
    if (!await checkIsValidMethod(uid, req.headers['security_key'], req.headers['email'])) {
        res.status(401).send({'message': 'Unauthorized'});
        return;
    }
    const body = JSON.parse(req.body);
    // Begin function

    const username = body.username;
    const userRef = db.collection('users');
    const snapshot = await userRef.where('username', '==', username).get();
    res.status(200).send({val: snapshot.empty})
});

exports.updateUserValues = functions.region(region).https.onRequest(async (req, res) => {
    const uid = req.headers['uid'];
    console.log('uid: ' + uid);
    if (!await checkIsValidMethod(uid, req.headers['security_key'], req.headers['email'])) {
        res.status(401).send({'message': 'Unauthorized'});
        return;
    }
    const body = JSON.parse(req.body);
    // Begin function

    if (body.person.birthdate != undefined && body.person.birthdate != null) {
          body.person.birthdate = new admin.firestore.Timestamp(body.person.birthdate,0)
    }
    let updated = false;
    const userRef = db.collection('users')
    await db.runTransaction(async (t) => {
        const docRead = await t.get(userRef.where('username', '==', body.person.username));

        if (docRead.empty) {
            await t.update(userRef.doc(uid), body.person);
            updated = true;
        }
    });
    res.status(200).send({"val": updated});
});

async function checkIsValidMethod(uid, security_key, email) {
    if (uid == null || security_key == null || email == null) {
        return false;
    }

    const hash = crypto.createHash('sha256').update(`${uid}:${email}:${secrets.cloudFunctionsSeed}`).digest('hex');

    if (security_key != hash) {
        return false;
    }

    let userExist = false;
    try {
        await admin.auth().getUserByEmail(email).then(user => {
            userExist = user.uid == uid;
        })
    } catch (e) {
        console.log(e);
    }
    return userExist;
}

/*exports.onNewItemUploaded = functions.region(region).storage.object().onFinalize(async (object) => {

    const fileBucket = object.bucket;
    const filePath = object.name;
    const contentType = object.contentType;
    const fileName = path.basename(filePath);

    if (filePath.split('/')[2] != 'items' || fileName != 'img') {
        return;
    }
    if (!contentType.startsWith('image/')) {
        return functions.logger.log('This is not an image.');
    }

    const bucket = admin.storage().bucket(fileBucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const metadata = {
        contentType: contentType,
    };
    await bucket.file(filePath).download({destination: tempFilePath});

    await spawn('convert', [tempFilePath, '-thumbnail', '600x600>', tempFilePath]);

    const thumbFileName = '600x600.png';
    const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
    await bucket.upload(tempFilePath, {
        destination: thumbFilePath,
        metadata: metadata,
    });
    return fs.unlinkSync(tempFilePath);
});*/

async function createNewWardrobe(uid, wardrobeName) {
    const wardrobe = {
        name: wardrobeName,
        create_time: admin.firestore.Timestamp.now(),
        is_default: true
    }
    await admin.firestore().collection('users').doc(uid).collection('wardrobes').add(wardrobe).then(async function(docRef) {

    });
}