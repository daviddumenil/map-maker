# map-maker
Generate high resolution Google Maps images with a Docker-based google-map-stitch wrapper

## Usage

The internal wrapper script can be called using:

```console
map-maker.rb <zoomLevel> [startX] [endX] [startY] [endY]
```

And will output a PNG to the container's /tmp.  So a 8000px x 8000px map of the world would be generated using:

```console
docker run -v /tmp:/tmp daviddumenil/map-maker ./map-maker.rb 5
```

Or a more detailed 2500px x 1800px view of Mexico using:

```console
docker run -v /tmp:/tmp daviddumenil/map-maker ./map-maker.rb 6 10 19 25 31
```

 Outputs a PNG to the container's /tmp dir so to generate a 30cm square map of the world at 300 DPI run:

