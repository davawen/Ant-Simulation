draw_set_color(c_white);

avrFps = (avrFps + fps_real)*.5;

draw_text(5, 5, string(avrFps) + "\n" + string(array_length(pheromones)));