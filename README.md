# Experimental Github Pipeline Upload

Fast pipeline upload without cloning your git repo. Ideal for generic pipeline steps configuration in the Web UI.

## Known Issues

When you upload a pipeline without checking out, the `BUILDKITE_COMMIT` and/or `git rev-parse HEAD` result will be inaccurate. This can lead to issues where variable interpolation is used.

## Example

In the buildkite web ui, edit your steps and paste the following. It will upload `.buildkite/pipeline.yml` from your repo.

```yml
steps:
  - label: ":pipeline:"
    plugins:
      - envato/github-pipeline-upload#v0.0.1: ~
```

To upload a custom pipeline file.

```yml
steps:
  - label: ":pipeline:"
    plugins:
      - envato/github-pipeline-upload#v0.0.1:
          file: folder/my-pipeline.yml
```

Requires the agent or pipeline to export `GITHUB_ACCESS_TOKEN` before the `command` hook.

## Configuration

### `file` (Option, string)

The location of the pipeline file somewhere in your git repo.

## Developing

Testing

```shell
docker-compose run --rm tests
```

Linting

```shell
docker-compose run --rm lint
```
