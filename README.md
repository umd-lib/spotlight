# Spotlight

Rails application utilizing the Blacklight "spotlight" plugin
(<https://github.com/projectblacklight/spotlight>) to showcase digital
collection resources.

----

> 🗒️ **Note**
>
> This implementation is a "proof-of-concept" implementation used for evaluation
> purposes.

----

## Application Creation

See [docs/ApplicationCreation.md](docs/ApplicationCreation.md) for information
on how this application as generated with the "projectblacklight/spotlight"
Rails application generator.

## Building the Docker Image for K8s Deployment

The following procedure uses the Docker "buildx" functionality and the
Kubernetes "build" namespace to build the Docker image for use with the
"[umd-lib/k8s-spotlight][k8s-spotlight]" Kubernetes configuration. This
procedure should work on both "arm64" and "amd64" MacBooks.

The image will be automatically pushed to the Nexus.

Local Machine Setup
See <https://github.com/umd-lib/k8s/blob/main/docs/DockerBuilds.md> in GitHub
for information about setting up a MacBook to use the Kubernetes "build"
namespace.

### Creating the Docker image

Creating the “spotlight” Docker image for Kubernetes

1. In an empty directory, clone the Git repository and switch into the
   directory:

    ```zsh
    $ git clone git@github.com:dsteelma-umd/spotlight.git
    $ cd spotlight
    ```

2. Checkout the appropriate Git tag, branch, or commit for the Docker image.

3. Set the `APP_TAG` environment variable:

    ```zsh
    $ export APP_TAG=<DOCKER_IMAGE_TAG>
    ```

   where \<DOCKER_IMAGE_TAG> is the Docker image tag to associate with th
   Docker image. This will typically be the Git tag for the application version,
   or some other identifier, such as a Git commit hash. For example, using
   the Git tag of "1.0.0":

    ```zsh
    $ export APP_TAG=1.0.0
    ```

4. Switch to the Kubernetes "build" namespace:

    ```zsh
    $ kubectl config use-context build
    ```

5. Build the Docker images using the Docker “buildx” tool:

    ```zsh
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/spotlight:$APP_TAG -f Dockerfile .
    $ docker buildx build --platform linux/amd64 --builder=kube --push --no-cache -t docker.lib.umd.edu/spotlight-solr:$APP_TAG -f Dockerfile.solr .
    ```

   The Docker images will be automatically pushed to the Nexus.

----

[k8s-spotlight]: https://github.com/umd-lib/k8s-spotlight
