FROM alpine
RUN apk add mlocate
RUN apk add bash
COPY scripts /scripts
RUN chmod 755 /scripts/*

ARG TESTFILES

RUN if [ ${TESTFILES} == "true" ]; then \
    echo "Adding test files" \
 &&   mkdir -p /netarkivet/001/filedir/ \
 &&   touch /netarkivet/001/filedir/1-1-20201015125643056-00000-ciblee_2015_nasharfocus.warc \
 &&   touch /netarkivet/001/filedir/1-metadata-1.warc \
 &&   touch /netarkivet/001/filedir/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz \
 &&   touch /netarkivet/001/filedir/1234-metadata-1.warc.gz \
 &&   touch /netarkivet/001/filedir/5282-metadata-1.warc.gz \
 &&   touch /netarkivet/001/filedir/Readme.md \
 &&   touch /netarkivet/001/filedir/dkcollection-1-1-metadata-1.warc.gz \
 else echo "No testfiles to be added" ; fi

RUN if [ "x$TESTFILES" == "xtrue" ] ; then \
    echo "Adding dummy test files" \
 &&   mkdir -p /netarkivet/001/dummydir/ \
 &&   touch /netarkivet/001/dummydir/1-1-20201015125643056-00000-ciblee_2015_nasharfocus.warc \
 &&   touch /netarkivet/001/dummydir/1-metadata-1.warc \
 &&   touch /netarkivet/001/dummydir/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz \
 &&   touch /netarkivet/001/dummydir/dummyfile \
else echo "No testfiles to be added" ; fi


CMD ["/scripts/update.sh"]