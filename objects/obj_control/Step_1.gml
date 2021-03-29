var regenerateQuad = quadTimer <= 0;

if(regenerateQuad)
{
    delete quad;
    
    quad = new Quad(new Rectangle(0, 0, rw, rh), 1, 12);
    quadTimer = 60;
}
else quadTimer--;

var deletePheromones = [],
    deletedPheromones = 0;

var l = array_length(pheromones);
for(i = 0; i < l; i++)
{
    if(regenerateQuad) quad.insert(pheromones[i]);
    
    if(pheromones[i].evaporate(0.05))
    {
        array_push(deletePheromones, i);
        deletedPheromones++;
    }
}

for(i = 0; i < deletedPheromones; i++)
{
    array_delete(pheromones, deletePheromones[i], 1);
}