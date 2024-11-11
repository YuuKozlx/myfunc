% 设置输入文件路径和输出文件路径
input_file = 'input_data.raw';  % 输入文件路径（.raw 文件）
output_file = 'output_data.raw';  % 输出文件路径（.raw 文件）

% 设置数据的维度
n_rows = 2176;
n_cols = 2176;
n_slices = 600;

% 调用函数进行转换并保存结果
convert_and_store_raw(input_file, output_file, n_rows, n_cols, n_slices);

function main(input_file, output_file, n_rows, n_cols, n_slices)
    % 主函数，完成读取、转换和保存数据
    % 输入:
    % input_file  - 输入文件路径（.mat 或 .raw 文件）
    % output_file - 输出文件路径（.mat 或 .raw 文件）
    % n_rows      - 数据的行数（仅用于 .raw 文件格式）
    % n_cols      - 数据的列数（仅用于 .raw 文件格式）
    % n_slices    - 数据的切片数（仅用于 .raw 文件格式）
    
    % 检查文件类型并处理
    if endsWith(input_file, '.mat')
        % 如果是 .mat 文件，调用处理 .mat 文件的函数
        convert_and_store_mat(input_file, output_file);
    elseif endsWith(input_file, '.raw')
        % 如果是 .raw 文件，调用处理 .raw 文件的函数
        convert_and_store_raw(input_file, output_file, n_rows, n_cols, n_slices);
    else
        error('不支持的文件格式. 仅支持 .mat 或 .raw 文件');
    end
end

function convert_and_store_mat(input_file, output_file)
    % 处理 .mat 文件，读取、转换并保存为新的 .mat 文件
    
    % 1. 读取输入的 .mat 文件
    data = load(input_file);
    
    % 假设输入数据变量名为 'float_image'
    % 根据实际情况修改变量名
    float_image = data.float_image;
    
    % 2. 将数据从 float 转换为 uint16
    uint16_image = float_to_uint16_3d(float_image);
    
    % 3. 将转换后的数据保存为新的 .mat 文件
    save(output_file, 'uint16_image');
    
    disp(['Conversion complete. Data saved to: ', output_file]);
end

function convert_and_store_raw(input_file, output_file, n_rows, n_cols, n_slices)
    % 处理 .raw 文件，读取、转换并保存为新的 .raw 文件
    
    % 1. 读取 .raw 文件
    fid = fopen(input_file, 'rb');
    if fid == -1
        error('无法打开输入文件');
    end
    
    % 读取浮动数据（假设是单精度浮动类型数据）
    float_image = fread(fid, [n_rows, n_cols * n_slices], 'float32');
    fclose(fid);
    
    % 2. 将数据从 float 转换为 uint16
    float_image = reshape(float_image, n_rows, n_cols, n_slices);
    uint16_image = float_to_uint16_3d(float_image);
    
    % 3. 将转换后的数据保存为新的 .raw 文件
    fid = fopen(output_file, 'wb');
    if fid == -1
        error('无法打开输出文件');
    end
    
    fwrite(fid, uint16_image, 'uint16');
    fclose(fid);
    
    disp(['Conversion complete. Data saved to: ', output_file]);
end

function uint16_image = float_to_uint16_3d(float_image)
    % 将 3D 浮动图像数据转换为 uint16 类型
    % 输入: float_image - 一个 2176x2176x600 的 3D 浮动数组
    % 输出: uint16_image - 转换后的 uint16 类型 3D 数组
    
    % 检查输入是否为浮动数据类型
    if ~isfloat(float_image)
        error('输入必须是浮动类型的数据');
    end
    
    % 获取数据的最小值和最大值
    min_val = min(float_image(:));
    max_val = max(float_image(:));
    
    % 归一化处理：将值映射到 [0, 1] 范围
    normalized_image = (float_image - min_val) / (max_val - min_val);
    
    % 将归一化的值映射到 uint16 范围 [0, 65535]
    uint16_image = uint16(normalized_image * 65535);
end
