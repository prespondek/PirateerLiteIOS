void main()
{
    vec4 color = texture2D(u_texture,v_tex_coord);
    
    if(color.w > 0.4) {
        color = vec4(18.0/255.0, 122.0/255.0, 232.0/255.0, 1.0);
    } else {
        color = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    gl_FragColor = color;
}
