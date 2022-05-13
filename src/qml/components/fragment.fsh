varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform vec2 a;
uniform vec2 b;
uniform vec2 c;
uniform vec2 d;

//uniform mat4 trans;


float Test(vec2 a,vec2 b,vec2 x){
    vec2 v = b-a;
    vec2 n = vec2(-v.y,v.x);
    return (dot(n,x)-dot(n,a));
}

void main(void)
{
    vec2 X = qt_TexCoord0;
//    gl_FragColor = texture2D(source, X);

    // jestli je bod X venku z abcd, tak pruhledna barva
    if ((Test(a,b,X) > 0.0) || (Test(b,d,X) > 0.0) || (Test(d,c,X) > 0.0) || (Test(c,a,X)>0.0)) {
        gl_FragColor = vec4(0.0);
        return;
    }


    vec2 i = a - c;
    vec2 j = b - a + c - d;
    float A = -j.y*(b.x-a.x) - j.x*(b.y-a.y);
    float B = -j.y*X.x + j.x*X.y + i.y*(b.x-a.x) + j.y*a.x - i.x*(b.y-a.y) - j.x*a.y;
    float C = (-i.y*X.x + i.x*X.y + i.y*a.x -i.x*a.y);


    A = ((b.x-a.x)*d.y + (a.y-b.y)*d.x + (a.x-b.x)*c.y + (b.y-a.y)*c.x);
    B = ((d.x-c.x-b.x+a.x)*X.y + (-d.y+c.y+b.y-a.y)*X.x + a.x*d.y - a.y*d.x + (b.x-2.0*a.x)*c.y + (2.0*a.y-b.y)*c.x);
    C = (c.x-a.x)*X.y + (a.y-c.y)*X.x + a.x*c.y - a.y*c.x;
    float D = B*B - 4.0*A*C;

    if (D < 0.0) {
        gl_FragColor=vec4(0.0);
        return;
    }

    float t;
    if (abs(A) < 0.01) {
        t = -C / B;
    } else {
        float t1 = (-B+sqrt(D)) / (2.0*A);
        float t0 = (-B-sqrt(D)) / (2.0*A);

        t = -1.0;
        if ((t0 >= 0.0) && (t0 <= 1.0)) {
            t = t0;
        }
        if((t1 >= 0.0) && (t1 <= 1.0)) {
            t = t1;
        }
    }


    vec2 M = a + t*(b-a);
    vec2 N = c + t*(d-c);
    float l = length(X-M)/length(N-M);


    gl_FragColor = texture2D(source, vec2(l,t));
//    gl_FragColor = texture2D(source, vec2(t,l));

//    gl_FragColor = vec4(t,l,0,1);

}



