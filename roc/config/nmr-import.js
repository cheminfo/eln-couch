'use strict';

const LDAP = require('ldapjs');
const nmr = require('eln-plugin/src/types/nmr');

var ldap = LDAP.createClient({
    url: 'ldap://ldap.epfl.ch'
});

var ldapCache = new Map();

function searchEmail(username) {
    return new Promise(function (resolve, reject) {
        var mail;
        if (ldapCache.has(username)) {
            mail = ldapCache.get(username);
            finish();
        } else {
            ldap.search('c=ch', {
                scope: 'sub',
                filter: 'uid=' + username,
                attributes: ['mail']
            }, function (err, res) {
                if (err) return reject(err);
                res.on('searchEntry', function (entry) {
                    if (!mail) {
                        mail = entry.object.mail;
                        ldapCache.set(username, mail);
                    }
                });
                res.on('error', reject);
                res.on('end', finish);
            });
        }
        function finish() {
            if (mail) resolve(mail);
            else reject(new Error('unknown user: ' + username));
        }
    });
}

var filenameReg = /^([^_]+)_([^_]+)_?(.*)\.([^.]+)\.(\d*)$/;

module.exports = {
    kind: 'sample',
    source: [
      '/mnt/eln/jcamp/nmr4313r',
      '/mnt/eln/jcamp/nmr4313l',
      '/mnt/eln/jcamp/nmr5313',
      '/mnt/eln/jcamp/nmrf492l'
    ],
    getID(filename) {
        var res = filenameReg.exec(filename);
        if (!res) throw new Error('Invalid file name: ' + filename);
        return [res[2], res[3]];
    },
    getOwner(filename) {
        var res = filenameReg.exec(filename);
        return searchEmail(res[1]);
    },
    parse(filename, contents) {
        var res = filenameReg.exec(filename);
        var toReturn = {
            jpath: 'spectra.nmr',
            content_type: 'chemical/x-jcamp-dx',
            reference: res[2] + '_' + res[3] + '_' + res[5] // experiment_batch_time
        };
        if (/j?dx/i.test(res[4])) { // parse jcamp
            toReturn.data = nmr.getMetadata(contents.toString());
            toReturn.field = 'jcamp';
        } else if (/fid/i.test(res[4])) {
            toReturn.data = {};
            toReturn.field = 'jcampFID';
        } else {
            throw new Error('unexpected file extension: ' + filename);
        }
        return toReturn;
    }
};
