//
//  SphereMatrixs.h
//  SHKit
//
//  Created by hsh on 2020/1/3.
//  Copyright © 2020 hsh. All rights reserved.
//


typedef struct SpherePoint SpherePoint;
//点信息
struct SpherePoint {
    CGFloat x;
    CGFloat y;
    CGFloat z;
};

static SpherePoint MakePoint(CGFloat x, CGFloat y, CGFloat z) {
    struct SpherePoint point;
    point.x = x;point.y = y;point.z = z;
    return point;
}



typedef struct SphereMatrixs SphereMatrixs;
//矩阵信息
struct SphereMatrixs {
    NSInteger column;
    NSInteger row;
    CGFloat matrix[4][4];
};


static SphereMatrixs MatrixMake(NSInteger column, NSInteger row) {
    SphereMatrixs matrix;
    matrix.column = column;
    matrix.row = row;
    for(NSInteger i = 0; i < column; i++){
        for(NSInteger j = 0; j < row; j++){
            matrix.matrix[i][j] = 0;
        }
    }
    return matrix;
}


static SphereMatrixs MatrixMakeFromArray(NSInteger column, NSInteger row, CGFloat *data) {
    SphereMatrixs matrix = MatrixMake(column, row);
    for (int i = 0; i < column; i ++) {
        CGFloat *t = data + (i * row);
        for (int j = 0; j < row; j++) {
            matrix.matrix[i][j] = *(t + j);
        }
    }
    return matrix;
}


static SphereMatrixs MatrixMutiply(SphereMatrixs a, SphereMatrixs b) {
    SphereMatrixs result = MatrixMake(a.column, b.row);
    for(NSInteger i = 0; i < a.column; i ++){
        for(NSInteger j = 0; j < b.row; j ++){
            for(NSInteger k = 0; k < a.row; k++){
                result.matrix[i][j] += a.matrix[i][k] * b.matrix[k][j];
            }
        }
    }
    return result;
}


static SpherePoint PointMakeRotation(SpherePoint point, SpherePoint direction, CGFloat angle) {

    if (angle == 0) {
        return point;
    }
    
    CGFloat temp2[1][4] = {point.x, point.y, point.z, 1};
    SphereMatrixs result = MatrixMakeFromArray(1, 4, *temp2);
    
    if (direction.z * direction.z + direction.y * direction.y != 0) {
        CGFloat cos1 = direction.z / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat sin1 = direction.y / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat t1[4][4] = {{1, 0, 0, 0}, {0, cos1, sin1, 0}, {0, -sin1, cos1, 0}, {0, 0, 0, 1}};
        SphereMatrixs m1 = MatrixMakeFromArray(4, 4, *t1);
        result = MatrixMutiply(result, m1);
    }
    
    if (direction.x * direction.x + direction.y * direction.y + direction.z * direction.z != 0) {
        CGFloat cos2 = sqrt(direction.y * direction.y + direction.z * direction.z) / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat sin2 = -direction.x / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat t2[4][4] = {{cos2, 0, -sin2, 0}, {0, 1, 0, 0}, {sin2, 0, cos2, 0}, {0, 0, 0, 1}};
        SphereMatrixs m2 = MatrixMakeFromArray(4, 4, *t2);
        result = MatrixMutiply(result, m2);
    }
    
    CGFloat cos3 = cos(angle);
    CGFloat sin3 = sin(angle);
    CGFloat t3[4][4] = {{cos3, sin3, 0, 0}, {-sin3, cos3, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
    SphereMatrixs m3 = MatrixMakeFromArray(4, 4, *t3);
    result = MatrixMutiply(result, m3);
    
    if (direction.x * direction.x + direction.y * direction.y + direction.z * direction.z != 0) {
        CGFloat cos2 = sqrt(direction.y * direction.y + direction.z * direction.z) / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat sin2 = -direction.x / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat t2_[4][4] = {{cos2, 0, sin2, 0}, {0, 1, 0, 0}, {-sin2, 0, cos2, 0}, {0, 0, 0, 1}};
        SphereMatrixs m2_ = MatrixMakeFromArray(4, 4, *t2_);
        result = MatrixMutiply(result, m2_);
    }
    
    if (direction.z * direction.z + direction.y * direction.y != 0) {
        CGFloat cos1 = direction.z / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat sin1 = direction.y / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat t1_[4][4] = {{1, 0, 0, 0}, {0, cos1, -sin1, 0}, {0, sin1, cos1, 0}, {0, 0, 0, 1}};
        SphereMatrixs m1_ = MatrixMakeFromArray(4, 4, *t1_);
        result = MatrixMutiply(result, m1_);
    }
    
    SpherePoint resultPoint = MakePoint(result.matrix[0][0], result.matrix[0][1], result.matrix[0][2]);
    
    return resultPoint;
}
