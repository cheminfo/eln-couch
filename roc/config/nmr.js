'use strict';

module.exports = {
  defaultEntry: function() {
    return {spectra:{nmr:[]}};
  },
  customDesign: {
    version: 4,
    views: {
      sample_toc: {
        map: function (doc) {
          var nmr = [];
          var nb1d = 0;
          var nb2d = 0;
          if (doc.$content.spectra && doc.$content.spectra.nmr) {
            nmr = doc.$content.spectra.nmr;
          }
          for (var i = 0; i < nmr.length; i++) {
            if (nmr[i].dimension === 1) nb1d++;
            else if (nmr[i].dimension === 2) nb2d++;
          }
          emitWithOwner(doc.$owners[0], {
            uuid: doc._id,
            id: doc.$id[0],
            batch: doc.$id[1],
            owner: doc.$owners[0],
            nb1d: nb1d,
            nb2d: nb2d
          });
        },
        withOwner: true
      }
    }
  }
};
