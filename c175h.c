/* Vector2 code at https://gist.github.com/Quackmatic/8f904e2f0cb7d144c0b7
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

#include "vector2.h"

bool line_collide(vec2 pos, vec2 vel, vec2 m1, vec2 m2, vec2 * poi)
{
    double xd = m2.x - m1.x, yd = m2.y - m1.y;
    double d1 = xd * vel.y, d2 = yd * vel.x;
    if(d1 != d2) /* not parallel */
    {
        double t =
            (yd * pos.x + xd * m1.y -
            yd * m1.x - xd * pos.y) / (d1 - d2);
        if(t >= 0) /* forward in time */
        {
            vec2 uv = vec_add(vec_mul(vel, t), pos);
            double m = (xd != 0) ?
                (uv.x - m1.x) / xd :
                (uv.y - m1.y) / yd; /* avoid division by 0 */
            if(m >= 0 && m <= 1)
            {
                poi->x = uv.x;
                poi->y = uv.y;
                return true;
            }
        }
    }
    return false;
}

vec2 get_reflected_vector(vec2 vel, vec2 m1, vec2 m2, vec2 poi)
{
    vec2 mirror_vector = vec_sub(m2, m1);
    vec2 normal = { mirror_vector.y, -mirror_vector.x };
    vec2 outward_vector = { -vel.x, -vel.y };
    normal = vec_norm(normal);
    return vec_sub(
        vec_mul(
            normal,
            2 * vec_dot(normal, outward_vector) / 
            vec_dot(normal, normal)),
        outward_vector);
}

int main(int argc, char * argv[])
{
    vec2 ray_pos, ray_vel, * lines;
    double distance;
    int line_count, i;
    scanf("%d", &line_count);
    lines = calloc(line_count * 2, sizeof(vec2));
    for(i = 0; i < line_count; i++)
    {
        scanf("%lf %lf %lf %lf", &lines[i * 2].x, &lines[i * 2].y, &lines[i * 2 + 1].x, &lines[i * 2 + 1].y);
    }
    scanf("%lf %lf %lf %lf %lf", &ray_pos.x, &ray_pos.y, &ray_vel.x, &ray_vel.y, &distance);
    ray_vel = vec_norm(ray_vel);
    while(distance > 0)
    {
        int closest_ml = -1;
        double closest_distance = 1e10;
        vec2 closest_poi = { 0.0, 0.0 };
        for(i = 0; i < line_count; i++)
        {
            vec2 poi = { 0.0, 0.0 };
            if(line_collide(ray_pos, ray_vel, lines[i * 2], lines[i * 2 + 1], &poi))
            {
                double d_to_mirror = vec_dist(ray_pos, poi);
                if(d_to_mirror > 0)
                {
                    if(d_to_mirror < closest_distance)
                    {
                        closest_distance = d_to_mirror;
                        closest_ml = i;
                        closest_poi = poi;
                    }
                }
            }
        }
        if(closest_distance > distance)
        {
            ray_pos = vec_add(ray_pos, vec_mul(ray_vel, distance));
            distance = 0;
        }
        else
        {
            ray_pos = closest_poi;
            ray_vel = get_reflected_vector(ray_vel, lines[closest_ml * 2], lines[closest_ml * 2 + 1], closest_poi);
            distance -= closest_distance;
        }
    }
    printf("%f %f\n", ray_pos.x, ray_pos.y);
    free(lines);
    return 0;
}