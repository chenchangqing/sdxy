# 4.OpenGL渲染技巧

## 学习内容

* 抗锯齿
* 多重采样 
* OpenGL基本变化 
* 投影矩阵-正投影 
* 投影矩阵-透视投影

## 一、抗锯齿

抗锯齿混合的2大功能:颜色组合、抗锯齿。

```cpp
//开启混合处理理
glEnable(GL_BLEND);
//指定混合因⼦子
GLBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA); 
//指定混合⽅方程式
glBlendEquation(GL_FUNC_ADD);

//对点进⾏行行抗锯⻮齿处理理 
glEnable(GL_POINT_SMOOTH); 
//对线进⾏行行抗锯⻮齿处理理 
glEnable(GL_LINE_SMOOTH);
//对多边形进⾏行行抗锯⻮齿处理理
glEnable(GL_POLYGON_SMOOTH);
```

未开启抗锯齿

![](../images/opengl_04_1_1.png)

开启抗锯齿

![](../images/opengl_04_1_2.png)

## 二、多重采样

```cpp
// 1.可以调⽤用 glutInitDisplayMode 添加采样缓存区 
glutInitDisplayMode(GLUT_MULTISAMPLE);
// 2.可以使⽤用glEnable| glDisable组合使⽤用GLUT_MULTISAMPLE 打开|关闭 多重采
glEnable(GLUT_MULTISAMPLE);
glDisable(GLUT_MULTISAMPLE);
// 3. 多重采样只正对多边形，点和线使用混合
glEnable(GL_POINT_SMOOTH);
glDisable(GL_POINT_SMOOTH);
glEnable(GL_LINE_SMOOTH);
glDisable(GL_LINE_SMOOTH); 
```

多重采样缓存区在默认情况下使用⽚段RGB值，并不包含颜色的alpha成分，我们可以通过调⽤用glEnable来修改这个行为:

* GL_SAMPLE_ALPHA_TO_COVERAGE 使⽤用alpha值
* GL_SAMPLE_ALPHA_TO_ON 使⽤alpha值并设为1，并使⽤它。 
* GL_SAMPLE_COVERAGE 使⽤glSampleCoverage所设置的值。

当启⽤ GL_SAMPLE_COVERAGE 时，可以使⽤glSampleCoverage函数允许指定一个特定的值，它是与⽚段覆盖值进⾏按位与操作的结果。

## 三、OpenGL基础变化

<object data="../pdfs/OpenGL 基础变化.pdf" type="application/pdf" width="700px" height="700px"> 
    <embed src="../pdfs/OpenGL 基础变化.pdf"> 
     This browser does not support PDFs. Please download the PDF to view it: <a href="../pdfs/OpenGL 基础变化.pdf">Download PDF</a>.</p> 
    </embed>
</object> 

## 四、数学知识

M3DVector3f,三维向量(x,y,z)

M3DVector4f,思维向量(x,y,z,w).w = 1.0

```cpp
//定义2个向量V1,V2
M3DVector3f v1 = {1.0,0.0,0.0};
M3DVector3f v2 = {0.0,1.0,0.0};

//方法1：获取V1,V2的点积，获取夹角的cos值
GLfloat value1 = m3dDotProduct3(v1, v2);
printf("V1V2 余弦值：%f\n",value1);

//通过acos()，获取value1的弧度值
GLfloat value2 = acos(value1);
printf("V1V2 弧度：%f\n",value2);

//方法2：获取V1，V2的夹角弧度值
GLfloat value3 = m3dGetAngleBetweenVectors3(v1, v2);
printf("V1V2 弧度：%f\n",value3);

//m3dRadToDeg 弧度->度数
//m3dDegToRad 度数->弧度
GLfloat value4 =  m3dRadToDeg(value3);
GLfloat value5 =  m3dDegToRad(90);

printf("V1V2角度：%f\n",value4);
printf("弧度：%f\n",value5);

//定义向量vector2
M3DVector3f vector2 = {0.0f,0.0f,0.0f};
//实现矩阵叉乘：结果，向量1，向量2
// 获得一个与v1v2所在平面垂直的新向量
// 叉乘的结果与v1v2的相乘顺序有关
m3dCrossProduct3(vector2, v1, v2);
printf("%f,%f,%f",vector2[0],vector2[1],vector2[2]);
```

## 四、案例

[源码](https://gitee.com/chenchangqing/iOS-OpenGL-Tutorials/tree/master/04_OpenGL渲染技巧)

### 4.1 抗锯齿+多重采样

```cpp
#include "GLTools.h"
#include "GLFrustum.h"

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

GLShaderManager shaderManager;
GLFrustum viewFrustum;
GLBatch smallStarBatch;
GLBatch mediumStarBatch;
GLBatch largeStarBatch;
GLBatch mountainRangeBatch;
GLBatch moonBatch;


#define SMALL_STARS     100
#define MEDIUM_STARS     40
#define LARGE_STARS      15

#define SCREEN_X        800
#define SCREEN_Y        600


// 选择菜单
void ProcessMenu(int value)
{
    switch(value)
    {
        case 1:
            //打开抗锯齿，并给出关于尽可能进行最佳的处理提示
            //设置混合因子
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            glEnable(GL_BLEND);
            glEnable(GL_POINT_SMOOTH);
            glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
            glEnable(GL_LINE_SMOOTH);
            glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
            glEnable(GL_POLYGON_SMOOTH);
            glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
            break;
            
        case 2:
            //关闭抗锯齿
            glDisable(GL_BLEND);
            glDisable(GL_LINE_SMOOTH);
            glDisable(GL_POINT_SMOOTH);
            glDisable(GL_POLYGON_SMOOTH);
            break;
            
        default:
            break;
    }
    
    // 触发重新绘制
    glutPostRedisplay();
}


//场景召唤
void RenderScene(void)
{
    //执行clear（颜色缓存区、深度缓冲区）
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //定义白色
    GLfloat vWhite [] = { 1.0f, 1.0f, 1.0f, 1.0f };
    //使用存储着色管理器中的平面着色器
    //参数1：平面着色器
    //参数2: 模型视图投影矩阵
    //参数3: 颜色，白色
    shaderManager.UseStockShader(GLT_SHADER_FLAT, viewFrustum.GetProjectionMatrix(), vWhite);

    //针对多边形开始多重采样
    glEnable(GLUT_MULTISAMPLE);
    
    //绘制小星星
    //点的大小
    glPointSize(1.0f);
    smallStarBatch.Draw();
    
    //绘制中星星
    glPointSize(4.0f);
    mediumStarBatch.Draw();
    
    //绘制大星星
    glPointSize(8.0f);
    largeStarBatch.Draw();
    
    // 绘制遥远的地平线
    glLineWidth(3.5);
    mountainRangeBatch.Draw();
    
    //绘制月亮
    moonBatch.Draw();
    
    //关闭多重采样
    glDisable(GLUT_MULTISAMPLE);
    
    // 交换缓冲区
    glutSwapBuffers();
}


//对渲染进行必要的初始化。
void SetupRC()
{
    M3DVector3f vVerts[SMALL_STARS];
    int i;
    
    shaderManager.InitializeStockShaders();
    
    // 小星星
    smallStarBatch.Begin(GL_POINTS, SMALL_STARS);
    for(i = 0; i < SMALL_STARS; i++)
    {
        vVerts[i][0] = (GLfloat)(rand() % SCREEN_X);
        vVerts[i][1] = (GLfloat)(rand() % (SCREEN_Y - 100)) + 100.0f;
        vVerts[i][2] = 0.0f;
    }
    smallStarBatch.CopyVertexData3f(vVerts);
    smallStarBatch.End();
    
    // 中星星
    mediumStarBatch.Begin(GL_POINTS, MEDIUM_STARS);
    for(i = 0; i < MEDIUM_STARS; i++)
    {
        vVerts[i][0] = (GLfloat)(rand() % SCREEN_X);
        vVerts[i][1] = (GLfloat)(rand() % (SCREEN_Y - 100)) + 100.0f;
        vVerts[i][2] = 0.0f;
    }
    mediumStarBatch.CopyVertexData3f(vVerts);
    mediumStarBatch.End();
    
    // 大星星
    largeStarBatch.Begin(GL_POINTS, LARGE_STARS);
    for(i = 0; i < LARGE_STARS; i++)
    {
        vVerts[i][0] = (GLfloat)(rand() % SCREEN_X);
        vVerts[i][1] = (GLfloat)(rand() % (SCREEN_Y - 100)) + 100.0f;
        vVerts[i][2] = 0.0f;
    }
    largeStarBatch.CopyVertexData3f(vVerts);
    largeStarBatch.End();
    
    M3DVector3f vMountains[12] = { 0.0f, 25.0f, 0.0f,
        50.0f, 100.0f, 0.0f,
        100.0f, 25.0f, 0.0f,
        225.0f, 125.0f, 0.0f,
        300.0f, 50.0f, 0.0f,
        375.0f, 100.0f, 0.0f,
        460.0f, 25.0f, 0.0f,
        525.0f, 100.0f, 0.0f,
        600.0f, 20.0f, 0.0f,
        675.0f, 70.0f, 0.0f,
        750.0f, 25.0f, 0.0f,
        800.0f, 90.0f, 0.0f };
    
    mountainRangeBatch.Begin(GL_LINE_STRIP, 12);
    mountainRangeBatch.CopyVertexData3f(vMountains);
    mountainRangeBatch.End();
    
    //月亮
    GLfloat x = 700.0f;
    GLfloat y = 500.0f;
    GLfloat r = 50.0f;
    GLfloat angle = 0.0f;
    
    moonBatch.Begin(GL_TRIANGLE_FAN, 34);
    int nVerts = 0;
    vVerts[nVerts][0] = x;
    vVerts[nVerts][1] = y;
    vVerts[nVerts][2] = 0.0f;
    for(angle = 0; angle < 2.0f * 3.141592f; angle += 0.2f) {
        nVerts++;
        vVerts[nVerts][0] = x + float(cos(angle)) * r;
        vVerts[nVerts][1] = y + float(sin(angle)) * r;
        vVerts[nVerts][2] = 0.0f;
    }
    nVerts++;
    
    vVerts[nVerts][0] = x + r;;
    vVerts[nVerts][1] = y;
    vVerts[nVerts][2] = 0.0f;
    moonBatch.CopyVertexData3f(vVerts);
    moonBatch.End();
    
    // 设置黑色背景
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f );
}



void ChangeSize(int w, int h)
{
    
    if(h == 0)
        h = 1;
    
    glViewport(0, 0, w, h);
    viewFrustum.SetOrthographic(0.0f, SCREEN_X, 0.0f, SCREEN_Y, -1.0f, 1.0f);
}

int main(int argc, char* argv[])
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    // 加了这句话开启了多重采样，没法显示抗锯齿
    //glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH|GLUT_MULTISAMPLE);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Smoothing Out The Jaggies");
    
    //创建菜单
    glutCreateMenu(ProcessMenu);
    glutAddMenuEntry("Antialiased Rendering",1);
    glutAddMenuEntry("Normal Rendering",2);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    
    glutReshapeFunc(ChangeSize);
    glutDisplayFunc(RenderScene);
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    SetupRC();
    glutMainLoop();
    
    return 0;
}
```

### 4.2 图形移动（矩阵变换）

```cpp

/*
 案例：实现矩阵的移动，利用矩阵的平移、旋转、综合变化等
 */
#include "GLTools.h"
#include "GLShaderManager.h"
#include "math3d.h"

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

GLBatch	squareBatch;
GLShaderManager	shaderManager;


GLfloat blockSize = 0.1f;
GLfloat vVerts[] = {
    -blockSize, -blockSize, 0.0f,
    blockSize, -blockSize, 0.0f,
    blockSize,  blockSize, 0.0f,
    -blockSize,  blockSize, 0.0f};

GLfloat xPos = 0.0f;
GLfloat yPos = 0.0f;



void SetupRC()
{
    //背景颜色
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f );
    
    shaderManager.InitializeStockShaders();
    
    // 加载三角形
    squareBatch.Begin(GL_TRIANGLE_FAN, 4);
    squareBatch.CopyVertexData3f(vVerts);
    squareBatch.End();
}

//移动（移动只是计算了X,Y移动的距离，以及碰撞检测）
void SpecialKeys(int key, int x, int y)
{
    GLfloat stepSize = 0.025f;
    
    
    if(key == GLUT_KEY_UP)
        yPos += stepSize;
    
    if(key == GLUT_KEY_DOWN)
        yPos -= stepSize;
    
    if(key == GLUT_KEY_LEFT)
        xPos -= stepSize;
    
    if(key == GLUT_KEY_RIGHT)
        xPos += stepSize;
    
    // 碰撞检测
    if(xPos < (-1.0f + blockSize)) xPos = -1.0f + blockSize;
    
    if(xPos > (1.0f - blockSize)) xPos = 1.0f - blockSize;
    
    if(yPos < (-1.0f + blockSize))  yPos = -1.0f + blockSize;
    
    if(yPos > (1.0f - blockSize)) yPos = 1.0f - blockSize;
    
    glutPostRedisplay();
}


void RenderScene(void)
{

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    
    M3DMatrix44f mFinalTransform, mTranslationMatrix, mRotationMatrix;
    
    //平移 xPos,yPos
    m3dTranslationMatrix44(mTranslationMatrix, xPos, yPos, 0.0f);
    
    // 每次重绘时，旋转5度
    static float yRot = 0.0f;
    yRot += 5.0f;
    m3dRotationMatrix44(mRotationMatrix, m3dDegToRad(yRot), 0.0f, 0.0f, 1.0f);
    
    //将旋转和移动的结果合并到mFinalTransform 中
    m3dMatrixMultiply44(mFinalTransform, mTranslationMatrix, mRotationMatrix);
    
    //将矩阵结果提交到固定着色器（平面着色器）中。
    shaderManager.UseStockShader(GLT_SHADER_FLAT, mFinalTransform, vRed);
    squareBatch.Draw();
    
    // 执行缓冲区交换
    glutSwapBuffers();
}



void ChangeSize(int w, int h)
{
    glViewport(0, 0, w, h);
}


int main(int argc, char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
    glutInitWindowSize(600, 600);
    glutCreateWindow("Move Block with Arrow Keys");
    
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    glutReshapeFunc(ChangeSize);
    glutDisplayFunc(RenderScene);
    glutSpecialFunc(SpecialKeys);
    
    SetupRC();
    
    glutMainLoop();
    return 0;
}
```

### 4.3 正交投影

```cpp

#include "GLTools.h"	
#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLGeometryTransform.h"
#include "GLBatch.h"

#include <math.h>
#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif


GLFrame             viewFrame;
GLFrustum           viewFrustum;
GLBatch             tubeBatch;
GLBatch             innerBatch;
//GLMatrixStack 堆栈矩阵
GLMatrixStack       modelViewMatix;
GLMatrixStack       projectionMatrix;

//几何变换的管道
GLGeometryTransform transformPipeline;
GLShaderManager     shaderManager;



// 召唤场景
void RenderScene(void)
{
    // 清屏、深度缓存
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //glEnable(GL_CULL_FACE);
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    
    //绘制前压栈，将数据保存进去
    modelViewMatix.PushMatrix(viewFrame);
    
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    GLfloat vGray[] = { 0.75f, 0.75f, 0.75f, 1.0f };
    
    //默认光源着色器
    //参数1：类型
    //参数2：模型视图矩阵
    //参数3：投影矩阵
    //参数4：颜色
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);
    tubeBatch.Draw();
    
    //默认光源着色器
    //参数1：类型
    //参数2：模型视图矩阵
    //参数3：投影矩阵
    //参数4：颜色
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vGray);
    innerBatch.Draw();
    
    //绘制完出栈，还原开始的数据
    modelViewMatix.PopMatrix();
    
    
    glutSwapBuffers();
}

//对图形上下文初始化
void SetupRC()
{
    //设置清屏颜色
    glClearColor(0.0f, 0.0f, 0.75f, 1.0f );
    
    //    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    //初始化着色器管理器
    shaderManager.InitializeStockShaders();
    
    
    tubeBatch.Begin(GL_QUADS, 200);
    
    float fZ = 100.0f;
    float bZ = -100.0f;
    
    //左面板的颜色、顶点、光照数据
    //颜色值
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    //光照法线
    //接受3个表示坐标的值，指定一条垂直于三角形表面的法线向量
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    //顶点数据
    tubeBatch.Vertex3f(-50.0f, 50.0f, 100.0f);
    
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
   
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);

    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);

    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);

    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    

    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    

    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(50.0f,-50.0f,bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, bZ);
    
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, bZ);
    

    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
    
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, bZ);
    
    tubeBatch.End();
    
    //内壁
    innerBatch.Begin(GL_QUADS, 40);
    
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f,35.0f,bZ);
    
   
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, fZ);
    
   
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
   
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, bZ);
    
    innerBatch.End();
    
}

void SpecialKeys(int key, int x, int y)
{
    if(key == GLUT_KEY_UP)
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 1.0f, 0.0f, 0.0f);
    
    if(key == GLUT_KEY_DOWN)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 1.0f, 0.0f, 0.0f);
    
    if(key == GLUT_KEY_LEFT)
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 0.0f, 1.0f, 0.0f);
    
    if(key == GLUT_KEY_RIGHT)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 0.0f, 1.0f, 0.0f);
    
    //刷新窗口
    glutPostRedisplay();
}


//启动demo，就会调用这个方法
void ChangeSize(int w, int h)
{
    
    if(h == 0)
        h = 1;
    
    // 设置视图窗口的尺寸
    glViewport(0, 0, w, h);
    
    //设置正投影矩阵
    /*
     void SetOrthographic(GLfloat xMin, GLfloat xMax, GLfloat yMin, GLfloat yMax, GLfloat zMin, GLfloat zMax)
     
     */
    viewFrustum.SetOrthographic(-130.0f, 130.0f, -130.0f, 130.0f, -130.0f, 130.0f);
    
    //1.获取投影矩阵 viewFrustum.GetProjectionMatrix()
    //2.将投影矩阵加载到projectionMatrix中
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    
    //设置变换管线以使用两个矩阵堆栈
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
}


int main(int argc, char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Orthographic Projection Example");
    glutReshapeFunc(ChangeSize);
    glutSpecialFunc(SpecialKeys);
    glutDisplayFunc(RenderScene);
    
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    SetupRC();
    
    glutMainLoop();
    return 0;
}
```

### 4.4 透视投影
```cpp
#include "GLTools.h"
#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLGeometryTransform.h"
#include "GLBatch.h"

#include <math.h>
#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif


GLFrame             viewFrame;
GLFrustum           viewFrustum;
GLBatch             tubeBatch;
GLBatch             innerBatch;
GLMatrixStack       modelViewMatix;
GLMatrixStack       projectionMatrix;
GLGeometryTransform transformPipeline;
GLShaderManager     shaderManager;




void RenderScene(void)
{
   
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
  
    glEnable(GL_DEPTH_TEST);
    
    
    modelViewMatix.PushMatrix(viewFrame);
    
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    GLfloat vGray[] = { 0.75f, 0.75f, 0.75f, 1.0f };
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);
    tubeBatch.Draw();
    
    
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vGray);
    innerBatch.Draw();
    
    modelViewMatix.PopMatrix();
    
    
    glutSwapBuffers();
}


void SetupRC()
{
   
    glClearColor(0.0f, 0.0f, 0.75f, 1.0f );
    
   
    glEnable(GL_DEPTH_TEST);
    
    shaderManager.InitializeStockShaders();
    viewFrame.MoveForward(450.0f);
    
    
    tubeBatch.Begin(GL_QUADS, 200);
    
    float fZ = 100.0f;
    float bZ = -100.0f;
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, 100.0f);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    // Right Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    // Top Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
    
    // Bottom Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);
    
    // Top length section ////////////////////////////
    // Normal points up Y axis
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);
    
    // Bottom section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    // Left section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    // Right Section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    
    // Pointing straight out Z
    // Left Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,fZ);
    
    // Right Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(50.0f,-50.0f,fZ);
    
    // Top Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f,fZ);
    
    // Bottom Panel
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,fZ);
    
    // Top length section ////////////////////////////
    // Normal points up Y axis
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, 1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f,50.0f,bZ);
    
    // Bottom section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(0.0f, -1.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    // Left section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    // Right Section
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, fZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, fZ);
    
    
    
    // Left Panel
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f,50.0f,bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-50.0f, 50.0f, bZ);
    
    // Right Panel
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(50.0f,-50.0f,bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    
    tubeBatch.Vertex3f(50.0f, 50.0f, bZ);
    
    // Top Panel
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 50.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, 35.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 35.0f, bZ);
    
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, 50.0f, bZ);
    
    // Bottom Panel
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -35.0f,bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(35.0f, -50.0f, bZ);
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -50.0f, bZ);
    
    
    tubeBatch.Normal3f(0.0f, 0.0f, -1.0f);
    tubeBatch.Color4f(1.0f, 0.0f, 0.0f, 1.0f);
    tubeBatch.Vertex3f(-35.0f, -35.0f, bZ);
    
    tubeBatch.End();
    
    
    innerBatch.Begin(GL_QUADS, 40);
    
    
    
    // Insides /////////////////////////////
    // Normal points up Y axis
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f,35.0f,bZ);
    
    // Bottom section
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(0.0f, 1.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, fZ);
    
    // Left section
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, 35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(-35.0f, -35.0f, fZ);
    
    // Right Section
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, fZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, -35.0f, bZ);
    innerBatch.Color4f(0.75f, 0.75f, 0.75f, 1.0f);
    innerBatch.Normal3f(-1.0f, 0.0f, 0.0f);
    innerBatch.Vertex3f(35.0f, 35.0f, bZ);
    
    innerBatch.End();
    
}

void SpecialKeys(int key, int x, int y)
{
    if(key == GLUT_KEY_UP)
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 1.0f, 0.0f, 0.0f);
    
    if(key == GLUT_KEY_DOWN)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 1.0f, 0.0f, 0.0f);
    
    if(key == GLUT_KEY_LEFT)
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 0.0f, 1.0f, 0.0f);
    
    if(key == GLUT_KEY_RIGHT)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 0.0f, 1.0f, 0.0f);
    
    // Refresh the Window
    glutPostRedisplay();
}


void ChangeSize(int w, int h)
{
    
    if(h == 0)
        h = 1;
    
    
    glViewport(0, 0, w, h);
    
    //设置正投影矩阵
    //viewFrustum.SetOrthographic(-130.0f, 130.0f, -130.0f, 130.0f, -130.0f, 130.0f);
    
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 1000.0f);
    
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
}


int main(int argc, char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Perspective Projection Example");
    glutReshapeFunc(ChangeSize);
    glutSpecialFunc(SpecialKeys);
    glutDisplayFunc(RenderScene);
    
    
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    
    SetupRC();
    
    glutMainLoop();
    return 0;
}
```