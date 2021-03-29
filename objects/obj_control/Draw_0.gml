draw_set_color(c_white);
quad.draw();

for(i = 0; i < array_length(pheromones); i++)
{
    draw_set_color(pheromones[i].c);
    draw_set_alpha(pheromones[i].weight);
    draw_circle(pheromones[i].pos.x, pheromones[i].pos.y, 1.5, false);
}
draw_set_alpha(1);

var l = array_length(ants);
for(i = 0; i < l; i++)
{
    ants[i].draw();
}

for(i = 0; i < 3; i++)
{
    food[i].draw();
}
nest.draw();