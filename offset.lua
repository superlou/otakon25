function offset(x, y, fn)
    gl.pushMatrix()
    gl.translate(x, y)
    fn()
    gl.popMatrix()
end

return offset