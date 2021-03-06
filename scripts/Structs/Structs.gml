#region Nest Mechanics

function Nest(_x/*: number*/, _y/*: number*/, _size/*: number*/, _amount/*: int*/) constructor
{
    x = _x;
    y = _y;
    size = _size;
    amount = _amount;
    
    food = 0; /// @is {int}
    
    static create = function(ants/*: Ant[]*/)/*->void*/
    {
        if(amount <= 0) return;
        
        var randAngle = random(2*pi);
        
        array_push(ants, new Ant(cos(randAngle)*self.size + self.x, sin(randAngle)*self.size + self.y, randAngle));
        
        amount--;
    }
    
    static draw = function()
    {
        draw_set_color(c_maroon);
        
        draw_circle(self.x, self.y, self.size, false);
        
        draw_set_color(c_white);
        draw_text_transformed(self.x, self.y, string(food), 2, 2, 0);
    }
}
/// @hint new Nest(x: number, y: number, size: number, amount: int)

function FoodCluster(_x/*: number*/, _y/*: number*/, _amount/*: int*/) constructor
{
    x = _x;
    y = _y;
    amount = _amount;
    id = irandom(10000);
    
    static draw = function()
    {
        draw_set_color(/*#*/0x98FB98);
        
        for(i = 0; i < amount; i++)
        {
            var randx = pseudo_random(id * i),
                randy = pseudo_random(id / i);
            
            randx = randx*randx*randx;
            randy = randy*randy*randy;
            
            draw_circle(self.x + (randx*2 - 1)*amount, self.y + (randy*2 - 1)*amount, 2.5, false);
        }
    }
}
/// @hint new FoodCluster(x: number, y: number, _amount: int)

#endregion

#region Ant Mechanics

function Ant(_x/*: number*/, _y/*: number*/, _a/*: number*/) constructor
{
    x = _x;                           
    y = _y;                           
    angle = _a;                       
    turnSpeed = pi/2;
    
    state = 0;
    timer = irandom(60); //Add pheromone every second
    
    avoiding = false;
    shift = 0;
    
    randomSteerSpeed = random(.4)+.8; 
    randomSteerAmount = 0;
    
    c = c_white;
    
    range = new Rectangle(self.x - 6, self.y - 6, 13, 13);
    
    // range = /// @is {Rectangle[]}
    // [
    //     new Rectangle(self.x+cos(angle-pi/4)*12 - 4, self.y+sin(angle-pi/4)*12 - 4, 9, 9),
    //     new Rectangle(self.x+cos(angle     )*12 - 4, self.y+sin(angle     )*12 - 4, 9, 9),
    //     new Rectangle(self.x+cos(angle+pi/4)*12 - 4, self.y+sin(angle+pi/4)*12 - 4, 9, 9)
    // ];
    
    weigth = [0, 0, 0];
    
    static avoid = function()/*->void*/
    {
        if(self.avoiding)
        {
            var point = collision_line_point(self.x, self.y, self.x+cos(self.angle)*30, self.y+sin(self.angle)*30, obj_obstacle, false, true);
            var mult = 1/60;
            
            if(point.inst != noone)
            {
                var dist = distance_mf0 self.x distance_mf1  point.x distance_mf2  self.y distance_mf3  point.y distance_mf4+1;
                
                mult = min(1/dist, 1);
            }
            
            var diff = angleDifference(self.angle, self.shift);
            
            var _amount = min(abs(diff), turnSpeed) * sign(diff) * mult;
            
            self.angle -= _amount;
            
            if(abs(diff) < .05) self.avoiding = false;
        }
        else
        {
            if(collision_line(self.x, self.y, self.x+cos(self.angle)*30, self.y+sin(self.angle)*30, obj_obstacle, false, true) != noone)
            {
                var a = false;
                var tries = 0;
                
                self.shift = pi/8 * choose(-1, 1);
                
                
                while(collision_line(self.x, self.y, self.x+cos(self.angle+self.shift)*30, self.y+sin(self.angle+self.shift)*30, obj_obstacle, false, true) != noone && tries++ < 16)
                {
                    self.shift = a ? self.shift*-1 : self.shift + sign(self.shift)*pi/8;
                    
                    a = !a;
                }
                
                self.avoiding = true;
            }
        }
    }
    
    static sense = function(quad/*: Quad*/)/*->void*/
    {
        self.range.x =  self.x - 6;
        self.range.y =  self.y - 6;
        
        // self.range[0].x = self.x + cos(self.angle-pi/4)*12 - 4;
        // self.range[0].y = self.y + sin(self.angle-pi/4)*12 - 4;
        
        // self.range[1].x = self.x + cos(self.angle     )*12 - 4;
        // self.range[1].y = self.y + sin(self.angle     )*12 - 4;
        
        // self.range[2].x = self.x + cos(self.angle+pi/4)*12 - 4;
        // self.range[2].y = self.y + sin(self.angle+pi/4)*12 - 4;
        
        if(self.avoiding) return;
        
        self.weigth = [0, 0, 0];
        
        var _points = quad.query(self.range, state);
        
        var _direction = new Vector2(cos(self.angle), sin(self.angle));
        
        var _l = array_length(_points);
        
        for(i = 0; i < _l; i++)
        {
            var _p = _points[i].pos;
            
            var _relativePos = new Vector2(_p.x - self.x, _p.y - self.y);
            
            if(_relativePos.sqrMag() < 1.5) continue;
            
            _relativePos.normalize();
            
            var dot = _direction.x * _relativePos.x + _direction.y * _relativePos.y;
            var cross = _direction.x * -_relativePos.y + _direction.y * _relativePos.x;
            
            if(dot < 0) continue; //More than 90 degrees
            
            if(cross > .2) self.weigth[0]++;
            else if(cross < -.2) self.weigth[2]++;
            else self.weigth[1]++;
        }
        
        // self.weigth =
        // [
        //     quad.queryCount(self.range[0]),
        //     quad.queryCount(self.range[1]),
        //     quad.queryCount(self.range[2])
        // ];
        
        if(self.weigth[1] > self.weigth[0] && self.weigth[1] > self.weigth[2]) //Continue forwards
        {
            self.angle += 0;
        }
        else if(self.weigth[0] > self.weigth[2])
        {
            self.angle -= self.turnSpeed * self.randomSteerSpeed / 30;
        }
        else if(self.weigth[2] > self.weigth[0])
        {
            self.angle += self.turnSpeed * self.randomSteerSpeed/30;
        }
        else if(self.weigth[1] <= self.weigth[0] && self.weigth[1] <= self.weigth[2]) //Wander
        {
            self.angle += self.randomSteerAmount * self.randomSteerSpeed * .5 / 60;
        }
    }
    
    static senseFood = function(food/*: FoodCluster[]*/)/*->void*/
    {
        
    }
    
    static trail = function(pheromones/*: Pheromone[]*/, quad/*: Quad*/)/*->void*/
    {
        if(timer > 0)
        {
            timer--;
            return;
        }
        
        var _p = new Pheromone(self.x, self.y, 1-self.state);
        
        array_push(pheromones, _p);
        quad.insert(_p);
        
        timer = 60;
    }
    
    static update = function()/*->void*/
    {
        self.x += cos(self.angle)/2;
        self.y += sin(self.angle)/2;
        
        self.randomSteerSpeed = random(.4)+.8;
        self.randomSteerAmount += random_gaussian(1)*self.randomSteerSpeed * .1 - (self.randomSteerAmount*.01);
        
        // console.log(self.randomSteerAmount);
    }
    
    static draw = function()
    {
        draw_set_color(c);
        
        var _cos = cos(self.angle),
            _sin = sin(self.angle);
        
        draw_line_width(self.x - _cos*2, self.y - _sin*2, self.x + _cos*2, self.y + _sin*2, 3);
    }
}
/// @hint new Ant(x: number, y: number, angle: number)

function Pheromone(_x/*: number*/, _y/*: number*/, _state/*: int*/) constructor
{
    pos = new Vector2(_x, _y);
    
    weight = 1;
    
    // 0 : To food
    // 1 : To home
    
    state = _state;

    c = _state == 1 ? c_blue : c_red; /// @is {int}
    
    static evaporate = function(amount/*: number*/)/*->bool*/
    {
        self.weight -= amount/60;
        
        return self.weight <= amount/60;
    }
}
/// @hint new Pheromone(x: number, y: number, state: int)

#endregion

#region Quadtree

function Vector2(_x/*: number*/, _y/*: number*/) constructor
{
    x = _x;
    y = _y;
    
    static Add = function(v/*: Vector2*/)/*->void*/
    {
        self.x += v.x;
        self.y += v.y;
    }
    
    static mult = function(c/*: number*/)/*->void*/
    {
        self.x *= c;
        self.y *= c;
    }
    
    static divide = function(c/*: number*/)/*->void*/
    {
        self.x /= c;
        self.y /= c;
    }
    
    static sqrMag = function()/*->number*/
    {
        return self.x*self.x + self.y*self.y;
    }
    
    static normalize = function()
    {
        var l = sqrt(self.x*self.x + self.y*self.y);
        
        self.x /= l;
        self.y /= l;
    }
}
/// @hint new Vector2(x: number, y: number)

function Rectangle(_x/*: number*/, _y/*: number*/, _w/*: number*/, _h/*: number*/) constructor
{
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    
    static intersects = function(r/*: Rectangle*/)/*->bool*/
    {
        if(self.x+self.w < r.x || r.x+r.w < self.x) return false;
        
        if(self.y+self.h < r.y || r.y+r.h < self.y) return false;
        
        return true;
    }
    
    static contain = function(pos/*: Vector2*/)/*->bool*/
    {
        var x2 = self.x + self.w,
            y2 = self.y + self.h;
        
        return pos.x >= min(self.x, x2) &&
               pos.y >= min(self.y, y2) &&
               pos.x <  max(self.x, x2) &&
               pos.y <  max(self.y, y2);
    }
    
    static minDistToPoint = function(pos/*: Vector2*/)/*->number*/
    {
        var x2 = self.x + self.w,
            y2 = self.y + self.h;
        
        var dx1 = pos.x - self.x,
            dy1 = pos.y - self.y,
            dx2 = dx1 - self.w,
            dy2 = dy1 - self.h;
            
        if(dx1*dx2 < 0) // X is between x1 and x2
        {
            return dy1*dy2 < 0 ? 0 : min(abs(dy1), abs(dy2));
        }
        else if(dy1*dy2 < 0) // Y is between y1 and y2
        {
            //We already know it can't be in the rectangle
            return min(abs(dx1), abs(dx2));
        }
        
        return min(distance_mf0 p.x distance_mf1  self.x distance_mf2  p.y distance_mf3  self.y distance_mf4, distance_mf0 p.x distance_mf1  x2 distance_mf2  p.y distance_mf3  y2 distance_mf4, distance_mf0 p.x distance_mf1  self.x distance_mf2  p.y distance_mf3  y2 distance_mf4, distance_mf0 p.x distance_mf1  x2 distance_mf2  p.y distance_mf3  self.y distance_mf4);
    }
    
    static draw = function()/*->void*/
    {
        draw_rectangle(self.x, self.y, self.x+self.w, self.y+self.h, true);
    }
}
/// @hint new Rectangle(x: number, y: number, width: number, height: number)

function Quad(_r/*: Rectangle*/, _c/*: int*/, _md/*: int*/) constructor
{
    #region Setup
    r = _r;          /// @is {Rectangle}
    
    r.x = round(r.x);
    r.y = round(r.y);
    r.w = round(r.w);
    r.h = round(r.h);
    
    maxDepth = _md;
    
    capacity = _c;   /// @is {int}
    points = [];     /// @is {Array<Pheromone>}
    divided = false; /// @is {bool}
    
    nw = noone;      /// @is {Quad}
    ne = noone;      /// @is {Quad}
    sw = noone;      /// @is {Quad}
    se = noone;      /// @is {Quad}
    #endregion
    
    static subdivide = function()/*->void*/
    {
        self.nw = new Quad(new Rectangle(self.r.x             , self.r.y             , self.r.w/2 - 1, self.r.h/2 - 1), self.capacity, self.maxDepth-1);
        self.ne = new Quad(new Rectangle(self.r.x + self.r.w/2, self.r.y             , self.r.w/2    , self.r.h/2 - 1), self.capacity, self.maxDepth-1);
        self.sw = new Quad(new Rectangle(self.r.x             , self.r.y + self.r.h/2, self.r.w/2 - 1, self.r.h/2    ), self.capacity, self.maxDepth-1);
        self.se = new Quad(new Rectangle(self.r.x + self.r.w/2, self.r.y + self.r.h/2, self.r.w/2    , self.r.h/2    ), self.capacity, self.maxDepth-1);
       
        self.divided = true;
    }
    
    static insert = function(p/*: Pheromone*/)/*->void*/
    {
        if(!self.r.contain(p.pos)) return;
        
        var l = array_length(self.points);
        
        if(l < self.capacity || maxDepth <= 0)
        {
            self.points[l] = p;
        }
        else
        {
            if(!self.divided) self.subdivide();
        }
        
        if(self.divided)
        {
            self.nw.insert(p);
            self.ne.insert(p);
            self.sw.insert(p);
            self.se.insert(p);
        }
    }
    
    static kNearest = function(pos/*: Vector2*/, k/*: int*/)/*->Pheromone[]*/
    {
        var stack/*: Quad[]*/ = [ self ];
        
        
    }
    
    // static kNearest = function(x: number, y: number, k: int, nodes: Quad[]?, found: Pheromone[]?)->Pheromone[]
    // {
    //     if(!self.r.contain(new Vector2(x, y))) return [];
        
    //     nodes ??= [];
    //     found ??= [];
        
    //     array_push(nodes, self);
        
    //     if(!self.divided) //Reached end of tree
    //     {
    //         var l = array_length(self.points);
    //         for(i = 0; i < l; i++)
    //         {
    //             if(array_length(found) > k) break;
                
    //             array_push(found, self.points[i]);
    //         }
    //     }
    //     else
    //     {
    //         self.nw.kNearest(x, y, k, nodes, found);
    //         self.ne.kNearest(x, y, k, nodes, found);
    //         self.sw.kNearest(x, y, k, nodes, found);
    //         self.se.kNearest(x, y, k, nodes, found);
            
    //         var l = array_length(self.points);
    //         for(i = 0; i < l; i++)
    //         {
    //             if(array_length(found) > k) break;
                
    //             array_push(found, self.points[i]);
    //         }
    //     }
        
    //     return found;
    // }
    
    static query = function(range/*: Rectangle*/, state/*: int*/, found/*: Pheromone[]?*/)/*->Pheromone[]*/
    {
        if (found == undefined) found = [];
        
        if(!self.r.intersects(range)) return found;
        
        let l = self.divided ? self.capacity : array_length(self.points);
        for(i = 0; i < l; i++)
        {
            let p = self.points[i];
            
            if((state == -1 || state == p.state) && range.contain(p.pos)) array_push(found, p);
        }
        
        if(self.divided)
        {
            self.nw.query(range, state, found);
            self.ne.query(range, state, found);
            self.sw.query(range, state, found);
            self.se.query(range, state, found);
        }
        
        return found;
    }
    
    ///Same as query, but only returns the number of points
    static queryCount = function(range/*: Rectangle*/, state/*: int*/, found/*: int?*/)/*->int*/
    {
        if (found == undefined) found = 0;
        
        if(!self.r.intersects(range)) return found;
        
        let l = self.divided ? self.capacity : array_length(self.points);
        for(let i = 0; i < l; i++)
        {
            let p = self.points[i];
            
            if((state == -1 || state == p.state) && range.contain(p.pos)) found++;
        }
        
        if(self.divided)
        {
            found = self.nw.queryCount(range, found);
            found = self.ne.queryCount(range, found);
            found = self.sw.queryCount(range, found);
            found = self.se.queryCount(range, found);
        }
        
        return found;
    }
    
    static draw = function()/*->void*/
    {
        draw_set_alpha(self.maxDepth/12);
        self.r.draw();
        
        if(self.divided)
        {
            self.nw.draw();
            self.ne.draw();
            self.sw.draw();
            self.se.draw(); 
        }
    }
}
/// @hint new Quad(rectangle: Rectangle, capacity: int, maxDepth: int)

#endregion