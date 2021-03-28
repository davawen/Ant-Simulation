
for(i = 0; i < array_length(pheromones); i++)
{
    draw_set_color(pheromones[i].c);
    draw_set_alpha(pheromones[i].weight);
    draw_circle(pheromones[i].x, pheromones[i].y, 1, false);
}

draw_set_alpha(1);

var l = array_length(ants);
for(i = 0; i < l; i++)
{
    
    ants[i].draw();
}