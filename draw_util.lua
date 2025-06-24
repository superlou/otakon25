function draw_image_xywh(image, x, y, w, h, mirror_x)
    if mirror_x then
        image:draw(x + w, y, x, y + h)
    else
        image:draw(x, y, x + w, y + h)
    end
end