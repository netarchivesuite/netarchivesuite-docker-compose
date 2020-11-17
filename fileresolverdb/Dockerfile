FROM alpine
RUN apk add mlocate
RUN apk add bash
COPY scripts /scripts
RUN chmod 755 /scripts/*

RUN if [ "x$TESTFILES" = "xtrue" ] ; then \
    echo "Adding test files" \
 &&   mkdir -p /kbhpillar/collection-netarkivet/ \
 &&   touch /kbhpillar/collection-netarkivet/1-1-20201015125643056-00000-ciblee_2015_nasharfocus.warc \
 &&   touch /kbhpillar/collection-netarkivet/1-metadata-1.warc \
 &&   touch /kbhpillar/collection-netarkivet/10-4-20161218234343407-00000-kb-test-har-003.kb.dk.warc.gz \
 &&   touch /kbhpillar/collection-netarkivet/1234-metadata-1.warc.gz \
 &&   touch /kbhpillar/collection-netarkivet/5282-metadata-1.warc.gz \
 &&   touch /kbhpillar/collection-netarkivet/Readme.md \
 &&   touch /kbhpillar/collection-netarkivet/dkcollection-1-1-metadata-1.warc.gz \
else ; \
    echo "No testfiles to be added" ; \
fi


CMD ["/scripts/update.sh"]