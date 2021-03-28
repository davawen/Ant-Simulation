function Vector2(_x/*: number*/, _y/*: number*/) constructor
{
    x = _x;
    y = _y;
    
    static Add = function(v/*: Vector2*/)/*->void*/
    {
        self.x += v.x;
        self.y += v.y;
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

// Vector2.Add = function(v1: Vector2, v2: Vector2)->Vector2
// {
//     return new Vector2(v1.x + v2.x, v1.y + v2.y);
// }

/// @hint new Vector2(x: number, y: number)
// /// @hint Vector2.add(v1: Vector2, v2: Vector2)->Vector2

function Pheromone(_x/*: number*/, _y/*: number*/, _signal/*: int*/) constructor
{
    x = _x;
    y = _y;
    
    weight = 1;
    signal = _signal;

    c = _signal == 0 ? c_blue : c_red; /// @is {int}
    
    static evaporate = function(amount/*: number*/)/*->bool*/
    {
        self.weight -= amount/60;
        
        return self.weight <= amount/60;
    }
}

/// @hint new Pheromone(x: number, y: number, signal: int)

function Ant(_x/*: number*/, _y/*: number*/, _a/*: number*/) constructor
{
    x = _x;                           
    y = _y;                           
    angle = _a;                       
    turnSpeed = pi/2;
    
    state = 0;
    
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
                var dist = sqrt(sqr(self.x - point.x) + sqr(self.y - point.y))+1;
                
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
        
        var _points = quad.query(self.range);
        
        var _direction = new Vector2(cos(self.angle), sin(self.angle));
        
        var _l = array_length(_points);
        for(i = 0; i < _l; i++)
        {
            var _p = _points[i];
            
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
    
    static update = function()/*->void*/
    {
        self.x += cos(self.angle)/2;
        self.y += sin(self.angle)/2;
        
        self.randomSteerSpeed = random(.4)+.8;
        self.randomSteerAmount += random_gaussian(1)*self.randomSteerSpeed - (self.randomSteerAmount*.01);
        
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
    
    static contain = function(p/*: Pheromone*/)/*->bool*/
    {
        return p.x >= min(self.x, self.x + self.w) &&
               p.y >= min(self.y, self.y + self.h) &&
               p.x <  max(self.x, self.x + self.w) &&
               p.y <  max(self.y, self.y + self.h);
    }
    
    static draw = function()/*->void*/
    {
        draw_rectangle(self.x, self.y, self.x+self.w+1, self.y+self.h+1, true);
    }
}

/// @hint new Rectangle(x: number, y: number, width: number, height: number)

function Quad(_r, _c) constructor
{
    #region Setup
    r = _r;          /// @is {Rectangle}
    
    r.x = round(r.x);
    r.y = round(r.y);
    r.w = round(r.w);
    r.h = round(r.h);
    
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
        self.nw = new Quad(new Rectangle(self.r.x             , self.r.y             , self.r.w/2, self.r.h/2), self.capacity);
        self.ne = new Quad(new Rectangle(self.r.x + self.r.w/2, self.r.y             , self.r.w/2, self.r.h/2), self.capacity);
        self.sw = new Quad(new Rectangle(self.r.x             , self.r.y + self.r.h/2, self.r.w/2, self.r.h/2), self.capacity);
        self.se = new Quad(new Rectangle(self.r.x + self.r.w/2, self.r.y + self.r.h/2, self.r.w/2, self.r.h/2), self.capacity);
       
        self.divided = true;
    }
    
    static insert = function(p/*: Pheromone*/)/*->void*/
    {
        if(!self.r.contain(p)) return;
        
        var l = array_length(self.points);
        
        if(l < self.capacity)
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
    
    static query = function(range/*: Rectangle*/, found/*: Pheromone[]?*/)/*->Pheromone[]*/
    {
        if (found == undefined) found = [];
        
        if(!self.r.intersects(range)) return found;
        
        if(self.divided)
        {
            for(i = 0; i < self.capacity; i++)
            {
                var p = self.points[i];
                
                if(range.contain(p)) array_push(found, p);
            }
            
            self.nw.query(range, found);
            self.ne.query(range, found);
            self.sw.query(range, found);
            self.se.query(range, found);
        }
        else
        {
            var l = array_length(self.points);
            for(i = 0; i < l; i++)
            {
                var p = self.points[i];
                
                if(range.contain(p)) array_push(found, p);
            }
        }
        
        return found;
    }
    
    ///Same as query, but only returns the number of points
    static queryCount = function(range/*: Rectangle*/, found/*: int?*/)/*->int*/
    {
        if (found == undefined) found = 0;
        
        if(!self.r.intersects(range)) return found;
        
        if(self.divided)
        {
            for(i = 0; i < self.capacity; i++)
            {
                var p = self.points[i];
                
                if(range.contain(p)) found++;
            }
            
            found = self.nw.queryCount(range, found);
            found = self.ne.queryCount(range, found);
            found = self.sw.queryCount(range, found);
            found = self.se.queryCount(range, found);
        }
        else
        {
            var l = array_length(self.points);
            for(i = 0; i < l; i++)
            {
                var p = self.points[i];
                
                if(range.contain(p)) found++;
            }
        }
        
        return found;
    }
    
    static draw = function()/*->void*/
    {
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
/// @hint new Quad(rectangle: Rectangle, capacity: int)