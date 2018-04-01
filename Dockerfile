FROM scratch
EXPOSE 8080
ENTRYPOINT ["/croc-hunter-jenkinsx"]
COPY ./bin/ /