var deletePheromones = [],
    deletedPheromones = 0;

if(quadTimer > 0)
{
    
    var l = array_length(pheromones);
    for(i = 0; i < l; i++)
    {
        if(pheromones[i].evaporate(0.05))
        {
            array_push(deletePheromones, i);
            deletedPheromones++;
        }
    }
    
    quadTimer--;
}
else
{
    delete quad[0];
    delete quad[1];
    
    quad[0] = new Quad(new Rectangle(0, 0, rw, rh), 4);
    quad[1] = new Quad(new Rectangle(0, 0, rw, rh), 4);
    
    var l = array_length(pheromones);
    for(i = 0; i < l; i++)
    {
        quad[pheromones[i].signal].insert(pheromones[i]);
        
        if(pheromones[i].evaporate(0.05))
        {
            array_push(deletePheromones, i);
            deletedPheromones++;
        }
    }
    
    quadTimer = 60;
}

for(i = 0; i < deletedPheromones; i++)
{
    array_delete(pheromones, deletePheromones[i], 1);
}