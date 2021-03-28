ants = []; /// @is {Ant[]}

for(i = 0; i < 300; i++)
{
    ants[i] = new Ant(rw/2, rh/2, i/300 * pi*2);
}

pheromones = []; /// @is {Pheromone[]}

quad = [ /// @is {Quad[]}
    new Quad(new Rectangle(0, 0, rw, rh), 4), //To home
    new Quad(new Rectangle(0, 0, rw, rh), 4) //To food
];

quadTimer = 60; // Regenerate quadtree every second

pressX = 0;
pressY = 0;

#region Camera
view_enabled = true;
view_visible[0] = true;

view_camera[0] = camera_create_view(0, 0, rw, rh);

function resize(zoom, ox, oy)
{
    //!#import camera.*
    
    if (ox == undefined) ox = .5;
    if (oy == undefined) oy = .5;
    
    var _w = camera_get_view_width(view_camera[0]),
        _h = camera_get_view_height(view_camera[0]),
        _x = camera_get_view_x(view_camera[0]),
        _y = camera_get_view_y(view_camera[0]);
        
    camera_set_view_pos(view_camera[0], _x + (_w - (_w*zoom))*ox, _y + (_h - (_h*zoom))*oy);
    camera_set_view_size(view_camera[0], _w*zoom, _h*zoom);
}
#endregion