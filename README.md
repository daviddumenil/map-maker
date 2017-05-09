# map-maker
Generate high resolution Google Maps images with a Docker-based google-map-stitch wrapper

## Usage

The internal wrapper script will output a map.png to /tmp can be called using:

```console
map-maker.rb <zoomLevel> [startX] [endX] [startY] [endY]
```

So a 8000px x 8000px map of the world would be generated using:

```console
docker run -v /tmp:/tmp daviddumenil/map-maker ./map-maker.rb 5
```

Or a more detailed 2500px x 1800px view of Mexico using:

```console
docker run -v /tmp:/tmp daviddumenil/map-maker ./map-maker.rb 6 10 19 25 31
```

Most of the heavy lifting is done using the excellent google-map-stitch Ruby library:

https://github.com/tkellen/google-map-stitch

