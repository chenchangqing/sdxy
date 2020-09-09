# 6.OpenGL模型视图矩阵绘制案例

[源码](https://gitee.com/chenchangqing/iOS-OpenGL-Tutorials/tree/master/05_OpenGL基础变化综合训练)

```cpp

#include "GLTools.h"	
#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLGeometryTransform.h"
#include "GLBatch.h"
#include "StopWatch.h"

#include <math.h>
#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif


GLFrustum           viewFrustum;
GLShaderManager     shaderManager;
GLTriangleBatch     torusBatch;


// 设置视口和投影矩阵
void ChangeSize(int w, int h)
{
    //防止除以零
    if(h == 0)
        h = 1;
    
    //将视口设置为窗口尺寸
    glViewport(0, 0, w, h);
    
    //设置透视投影
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 1000.0f);
}


//召唤场景
void RenderScene(void)
{
    //建立基于时间变化的动画
    static CStopWatch rotTimer;
    
    //当前时间 * 60s
    float yRot = rotTimer.GetElapsedSeconds() * 60.0f;
    
    //清除屏幕、深度缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 矩阵变量
    M3DMatrix44f mTranslate, mRotate, mModelview, mModelViewProjection;
    
    //创建一个4*4矩阵变量，将花托沿着Z轴负方向移动2.5个单位长度
    m3dTranslationMatrix44(mTranslate, 0.0f, 0.0f, -2.5f);
    
    //创建一个4*4矩阵变量，将花托在Y轴上渲染yRot度，yRot根据经过时间设置动画帧率
    m3dRotationMatrix44(mRotate, m3dDegToRad(yRot), 0.0f, 1.0f, 0.0f);
    // m3dRotationMatrix44(mRotate, m3dDegToRad(yRot), 1.0f, 0.0f, 0.0f);
    
    //为mModerView 通过矩阵旋转矩阵、移动矩阵相乘，将结果添加到mModerView上
    m3dMatrixMultiply44(mModelview, mTranslate, mRotate);
    
    // 将模型视图矩阵的投影矩阵，
    // 将投影矩阵乘以模型视图矩阵，将变化结果通过矩阵乘法应用到mModelViewProjection矩阵上
    m3dMatrixMultiply44(mModelViewProjection, viewFrustum.GetProjectionMatrix(),mModelview);
    
    // 将这个已完成的矩阵传递给着色器，并渲染这个圆环面。
    //绘图颜色
    GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    
    //通过平面着色器提交矩阵，和颜色。
    //平面着色器的工作只是使用提供矩阵来顶点来进行转换，并且使用指定的颜色对几何图形进行着色以得到实心几何图形
    shaderManager.UseStockShader(GLT_SHADER_FLAT, mModelViewProjection, vBlack);
    //开始绘图
    torusBatch.Draw();
    
    
    // 交换缓冲区，并立即刷新
    glutSwapBuffers();
    glutPostRedisplay();
}


void SetupRC()
{
  
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f );
    
    glEnable(GL_DEPTH_TEST);
    
    shaderManager.InitializeStockShaders();
    
    // 形成一个圆环
    gltMakeTorus(torusBatch, 0.4f, 0.15f, 30, 30);
    
    //形成一个球
    gltMakeSphere(torusBatch, 0.4f, 10, 20);
    
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}



int main(int argc, char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(800, 600);
    glutCreateWindow("ModelViewProjection Example");
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