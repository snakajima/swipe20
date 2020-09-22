# Swipe 2.0

## What is Swipe 2.0?

Swipe 2.0 is a domain-specific, declarative language to describe 2D and 2.5D animations consists of texts, images and vector graphics. 
It is derived from [Swipe 1.0]([https://github.com/swipe-org/swipe), which was designed as a platform for interactive & animated contents. 
Swipe 2.0 inherits many design principles from Swipe 1.0, but it is simpler and lightweight. 

## Swipe Language 

A Swipe file (extension .swipe or .json) is a JSON file, which describes a *scene*. A *scene* contains one or more *frames*, which desribes key-frames. 
A *frame* contains one or more *elements* (texts, images and vector graphics), which describes its presentation. 

Here is a smple example, which displays a text "Hello World" at the specified location in the first frame, and move it 100-units right in the second frame. 

```
{
    scene: {
        backgroundColor: "yellow",
        frames: [{
            id: "id0",
            text: "Hello World",
            foregroundColor: "black",
            x: 100, y:100, w:300, h:100
        },{
            id: "id0",
            x: 200,
            rotate: 30
        }]
    }
}
```

Please notice that the second frame describes only the difference from the first frame. 

