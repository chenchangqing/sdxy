# 8.OpenGL公转自转案例

[源码](https://gitee.com/chenchangqing/iOS-OpenGL-Tutorials/tree/master/05_OpenGL基础变化综合训练)


```cpp
#include "GLTools.h"
#include "GLShaderManager.h"
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"
#include "StopWatch.h"

#include <math.h>
#include <stdio.h>

#ifdef __APPLE__
#include <glut/glut.h>
#else
#define FREEGLUT_STATIC
#include <GL/glut.h>
#endif

//**4、添加附加随机球 
#define NUM_SPHERES 50
GLFrame spheres[NUM_SPHERES];

GLShaderManager		shaderManager;			// 着色器管理器
GLMatrixStack		modelViewMatrix;		// 模型视图矩阵
GLMatrixStack		projectionMatrix;		// 投影矩阵
GLFrustum			viewFrustum;			// 视景体
GLGeometryTransform	transformPipeline;		// 几何图形变换管道

GLTriangleBatch		torusBatch;             // 花托批处理
GLBatch				floorBatch;             // 地板批处理

//**2、定义公转球的批处理（公转自转）**
GLTriangleBatch     sphereBatch;            //球批处理

//**3、角色帧 照相机角色帧（全局照相机实例）
GLFrame             cameraFrame;


void SetupRC()
{
    // 初始化着色器管理器
    shaderManager.InitializeStockShaders();
    
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    
    //开启多边形模型
    //**4、关闭线框渲染模式
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    //设置清屏颜色到颜色缓存区
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    //绘制甜甜圈
    gltMakeTorus(torusBatch, 0.4f, 0.15f, 30, 30);
    
    //**2、 绘制球(公转自转)**
    gltMakeSphere(sphereBatch, 0.1f, 26, 13);
    
    //往地板floorBatch批处理中添加顶点数据
    floorBatch.Begin(GL_LINES, 324);
    for(GLfloat x = -20.0; x <= 20.0f; x+= 0.5) {
        floorBatch.Vertex3f(x, -0.55f, 20.0f);
        floorBatch.Vertex3f(x, -0.55f, -20.0f);
        
        floorBatch.Vertex3f(20.0f, -0.55f, x);
        floorBatch.Vertex3f(-20.0f, -0.55f, x);
    }
    floorBatch.End();
    
    
    //**4、在场景中随机位置对球体进行初始化
    //随机放置球体
    for (int i = 0; i < NUM_SPHERES; i++) {
        
        //y轴不变，X,Z产生随机值
        GLfloat x = ((GLfloat)((rand() % 400) - 200 ) * 0.1f);
        GLfloat z = ((GLfloat)((rand() % 400) - 200 ) * 0.1f);
        
        //在y方向，将球体设置为0.0的位置，这使得它们看起来是飘浮在眼睛的高度
        //对spheres数组中的每一个顶点，设置顶点数据
        spheres[i].SetOrigin(x, 0.0f, z);
    }
}


// 屏幕更改大小或已初始化
void ChangeSize(int nWidth, int nHeight)
{
    glViewport(0, 0, nWidth, nHeight);
    
    // 创建投影矩阵，。
    viewFrustum.SetPerspective(35.0f, float(nWidth)/float(nHeight), 1.0f, 100.0f);
    
    //viewFrustum.GetProjectionMatrix()  获取viewFrustum投影矩阵
    //并将其加载到投影矩阵堆栈上
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    
    // 设置变换管道以使用两个矩阵堆栈（变换矩阵modelViewMatrix ，投影矩阵projectionMatrix）
    //初始化GLGeometryTransform 的实例transformPipeline.通过将它的内部指针设置为模型视图矩阵堆栈 和 投影矩阵堆栈实例，来完成初始化
    //当然这个操作也可以在SetupRC 函数中完成，但是在窗口大小改变时或者窗口创建时设置它们并没有坏处。而且这样可以一次性完成矩阵和管线的设置。
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}


//进行调用以绘制场景
void RenderScene(void)
{
    // 颜色值 地板颜色、甜甜圈颜色
    static GLfloat vFloorColor[] = { 0.0f, 1.0f, 0.0f, 1.0f};
    static GLfloat vTorusColor[] = { 1.0f, 0.0f, 0.0f, 1.0f };
   
    //**2、球颜色（公转自转）**
    static GLfloat vSphereColor[] = { 0.0f, 0.0f, 1.0f, 1.0f };

    
    // 基于时间动画
    static CStopWatch	rotTimer;
    float yRot = rotTimer.GetElapsedSeconds() * 60.0f;
    
    // 清除颜色缓存区和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    //将当前的模型视图矩阵压入矩阵堆栈（单位矩阵）
    //因为我们先绘制地面，而地面是不需要有任何变换的。所以在开始渲染时保证矩阵状态，然后在结束时使用相应的PopMatrix恢复它。这样就不必在每一次渲染时重载单位矩阵了。
    modelViewMatrix.PushMatrix();
    
    
    //**3、设置照相机矩阵
    M3DMatrix44f mCamera;
    //**3、从camraFrame中获取一个4*4的矩阵；
    cameraFrame.GetCameraMatrix(mCamera);
    //**3、将照相机矩阵压入模型视图堆栈中
    modelViewMatrix.PushMatrix(mCamera);
    
    //**4、添加光源
    //光源位置的全局坐标存储在vLightPos变量中，其中包含了光源位置x坐标、y坐标、z坐标和w坐标。我们必须保留w坐标为1.0。因为无法用一个3分量去乘以4*4矩阵。
    M3DVector4f vLightPos = {0.0f,10.0f,5.0f,1.0f};
    M3DVector4f vLightEyePos;
    //将照相机矩阵mCamera 与 光源矩阵vLightPos 相乘获得vLightEyePos 矩阵
    m3dTransformVector4(vLightEyePos, vLightPos, mCamera);
    
    
    // 绘制地面（平面着色器）
    /*
     参数1:GLT_SHADER_FLAT
     参数2：4*4矩阵（模型视图投影矩阵）
     参数3：颜色数组
     */
    shaderManager.UseStockShader(GLT_SHADER_FLAT,transformPipeline.GetModelViewProjectionMatrix(),vFloorColor);
    

    floorBatch.Draw();
    
    
    //**4、绘制悬浮球体
    //使用sphereBatch 绘制。
    //思路：循环绘制50个蓝色悬浮球体，绘制一个压栈一个，绘制完成出栈一个
    for (int i = 0; i < NUM_SPHERES; i++) {
        modelViewMatrix.PushMatrix();
        modelViewMatrix.MultMatrix(spheres[i]);
        
       // shaderManager.UseStockShader(GLT_SHADER_FLAT,transformPipeline.GetModelViewProjectionMatrix(),vSphereColor);
       //**4、绘制光源，修改着色器管理器
        /**绘制光源，修改着色器管理器
         参数1：GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF
         参数2：模型视图矩阵
         参数3：投影矩阵
         参数4：视点坐标系中的光源位置
         参数5：基本漫反射颜色
         参数6：颜色
         */
        shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
                                     transformPipeline.GetProjectionMatrix(), vLightEyePos, vSphereColor);
        sphereBatch.Draw();
        
        modelViewMatrix.PopMatrix();
        
    }
    
    
    // 绘制旋转甜甜圈
    //modelViewMatrix 顶部矩阵沿着z轴移动2.5单位
    modelViewMatrix.Translate(0.0f, 0.0f, -2.5f);
    
    //**2、保存平移（公转自转）**
    modelViewMatrix.PushMatrix();
    
    //modelViewMatrix 顶部矩阵旋转yRot度
    modelViewMatrix.Rotate(yRot, 0.0f, 1.0f, 0.0f);
  
    //使用平面着色器 变换管道中的投影矩阵 和 变换矩阵 相乘的矩阵，指定甜甜圈颜色
    //shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vTorusColor);
    //**4、绘制光源，修改着色器管理器
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(), vLightEyePos, vTorusColor);
    
    //开始绘制
    torusBatch.Draw();
    
    // 恢复modelViewMatrix矩阵，移除矩阵堆栈
    //使用PopMatrix推出刚刚变换的矩阵，然后恢复到单位矩阵
    modelViewMatrix.PopMatrix();
    
    //**2、绘制公转球体（公转自转）**
    modelViewMatrix.Rotate(yRot * -2.0f, 0.0f, 1.0f, 0.0f);
    modelViewMatrix.Translate(0.8f, 0.0f, 0.0f);
   //shaderManager.UseStockShader(GLT_SHADER_FLAT,transformPipeline.GetModelViewProjectionMatrix(),vSphereColor);
   //**4、绘制光源，修改着色器管理器
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF, transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(), vLightEyePos, vSphereColor);
    sphereBatch.Draw();
    
    //**2、恢复矩阵(公转自转)**
    modelViewMatrix.PopMatrix();

    //**3、恢复矩阵
    modelViewMatrix.PopMatrix();
    
    //执行缓存区交换
    glutSwapBuffers();
    
    // 告诉glut在显示一遍
    glutPostRedisplay();
}


//**3.移动照相机参考帧，来对方向键作出响应
void SpeacialKeys(int key,int x,int y)
{

    float linear = 0.1f;
    float angular = float(m3dDegToRad(5.0f));
    
    if (key == GLUT_KEY_UP) {
       
        //MoveForward 平移
        cameraFrame.MoveForward(linear);
    }
    
    if (key == GLUT_KEY_DOWN) {
        cameraFrame.MoveForward(-linear);
    }
    
    if (key == GLUT_KEY_LEFT) {
        //RotateWorld 旋转
        cameraFrame.RotateWorld(angular, 0.0f, 1.0f, 0.0f);
    }
    
    if (key == GLUT_KEY_RIGHT) {
        cameraFrame.RotateWorld(-angular, 0.0f, 1.0f, 0.0f);
    }
    

    
}


int main(int argc, char* argv[])
{
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(800,600);
    
    glutCreateWindow("OpenGL SphereWorld");
    
    glutReshapeFunc(ChangeSize);
    glutDisplayFunc(RenderScene);
    glutSpecialFunc(SpeacialKeys);
    
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