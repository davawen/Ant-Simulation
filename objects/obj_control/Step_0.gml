
if(mouse_check_button_pressed(mb_left))
{
    // array_push(ants, new Ant(mouse_x, mouse_y, random(pi)));
    array_push(pheromones, new Pheromone(mouse_x, mouse_y, 1));
}

if(mouse_check_button_pressed(mb_right))
{
    pressX = mouse_x;
    pressY = mouse_y;
}

if(mouse_check_button_released(mb_right))
{
    array_push(ants, new Ant(pressX, pressY, arctan2(mouse_y-pressY, mouse_x-pressX)));
}

#region Update

nest.create(ants);

var l = array_length(ants);
for(i = 0; i < l; i++)
{
    ants[i].avoid();
    ants[i].sense(quad);
    ants[i].trail(pheromones, quad);
    ants[i].update();
}

#endregion

#region Camera
if(mouse_wheel_up())
{
    resize(.8, window_mouse_get_x()/window_get_width(), window_mouse_get_y()/window_get_height());
}
else if(mouse_wheel_down())
{
    resize(1.2, window_mouse_get_x()/window_get_width(), window_mouse_get_y()/window_get_height());
}
#endregion