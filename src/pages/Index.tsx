import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Shield, 
  Users, 
  GraduationCap, 
  BookOpen, 
  Trophy, 
  Heart, 
  Zap,
  LogOut,
  Settings,
  BarChart3
} from 'lucide-react';

const Index = () => {
  const { user, profile, signOut } = useAuth();

  const handleSignOut = async () => {
    await signOut();
  };

  const getDashboardContent = () => {
    switch (profile?.role) {
      case 'admin':
        return (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total Users</CardTitle>
                  <Users className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">1,234</div>
                  <p className="text-xs text-muted-foreground">+10% from last month</p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Active Modules</CardTitle>
                  <BookOpen className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">45</div>
                  <p className="text-xs text-muted-foreground">+5 new this week</p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
                  <BarChart3 className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">78%</div>
                  <p className="text-xs text-muted-foreground">+2% from last week</p>
                </CardContent>
              </Card>
            </div>
            <Card>
              <CardHeader>
                <CardTitle>Admin Controls</CardTitle>
                <CardDescription>Manage the DisasterPrep Learn platform</CardDescription>
              </CardHeader>
              <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Button className="justify-start h-12">
                  <Users className="mr-2 h-4 w-4" />
                  Manage Users
                </Button>
                <Button className="justify-start h-12" variant="outline">
                  <BookOpen className="mr-2 h-4 w-4" />
                  Manage Modules
                </Button>
                <Button className="justify-start h-12" variant="outline">
                  <Trophy className="mr-2 h-4 w-4" />
                  Manage Achievements
                </Button>
                <Button className="justify-start h-12" variant="outline">
                  <Settings className="mr-2 h-4 w-4" />
                  System Settings
                </Button>
              </CardContent>
            </Card>
          </div>
        );
      case 'teacher':
        return (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>My Students</CardTitle>
                  <CardDescription>Monitor student progress and performance</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold mb-2">32 Active Students</div>
                  <Button className="w-full">View All Students</Button>
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>Course Management</CardTitle>
                  <CardDescription>Create and manage learning content</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold mb-2">12 Modules</div>
                  <Button className="w-full" variant="outline">Manage Modules</Button>
                </CardContent>
              </Card>
            </div>
            <Card>
              <CardHeader>
                <CardTitle>Quick Actions</CardTitle>
              </CardHeader>
              <CardContent className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Button className="justify-start h-12">
                  <BookOpen className="mr-2 h-4 w-4" />
                  Create Module
                </Button>
                <Button className="justify-start h-12" variant="outline">
                  <BarChart3 className="mr-2 h-4 w-4" />
                  View Reports
                </Button>
                <Button className="justify-start h-12" variant="outline">
                  <Users className="mr-2 h-4 w-4" />
                  Student Progress
                </Button>
              </CardContent>
            </Card>
          </div>
        );
      default: // student
        return (
          <div className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle>Your Progress</CardTitle>
                  <CardDescription>Continue your disaster preparedness journey</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <span>Modules Completed</span>
                      <Badge>3/12</Badge>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-blue-600 h-2 rounded-full" style={{ width: '25%' }}></div>
                    </div>
                    <Button className="w-full">Continue Learning</Button>
                  </div>
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>Achievements</CardTitle>
                  <CardDescription>Your earned badges and points</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center">
                      <span>Total Points</span>
                      <Badge variant="secondary">150</Badge>
                    </div>
                    <div className="flex justify-between items-center">
                      <span>Badges Earned</span>
                      <Badge variant="secondary">🏆 2</Badge>
                    </div>
                    <Button className="w-full" variant="outline">View All Achievements</Button>
                  </div>
                </CardContent>
              </Card>
            </div>
            <Card>
              <CardHeader>
                <CardTitle>Learning Modules</CardTitle>
                <CardDescription>Choose what you want to learn today</CardDescription>
              </CardHeader>
              <CardContent className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <Button className="justify-start h-16 flex-col">
                  <Shield className="h-6 w-6 mb-1" />
                  <span>Earthquake Safety</span>
                </Button>
                <Button className="justify-start h-16 flex-col" variant="outline">
                  <Heart className="h-6 w-6 mb-1" />
                  <span>CPR Training</span>
                </Button>
                <Button className="justify-start h-16 flex-col" variant="outline">
                  <Zap className="h-6 w-6 mb-1" />
                  <span>Emergency Kit</span>
                </Button>
                <Button className="justify-start h-16 flex-col" variant="outline">
                  <Shield className="h-6 w-6 mb-1" />
                  <span>Fire Safety</span>
                </Button>
                <Button className="justify-start h-16 flex-col" variant="outline">
                  <Heart className="h-6 w-6 mb-1" />
                  <span>First Aid Basics</span>
                </Button>
                <Button className="justify-start h-16 flex-col" variant="outline">
                  <Zap className="h-6 w-6 mb-1" />
                  <span>Flood Response</span>
                </Button>
              </CardContent>
            </Card>
          </div>
        );
    }
  };

  const getRoleIcon = () => {
    switch (profile?.role) {
      case 'admin':
        return <Shield className="h-5 w-5" />;
      case 'teacher':
        return <Users className="h-5 w-5" />;
      default:
        return <GraduationCap className="h-5 w-5" />;
    }
  };

  const getRoleColor = () => {
    switch (profile?.role) {
      case 'admin':
        return 'text-red-600';
      case 'teacher':
        return 'text-blue-600';
      default:
        return 'text-green-600';
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <Shield className="h-8 w-8 text-blue-600" />
              <h1 className="text-2xl font-bold text-gray-900">DisasterPrep Learn</h1>
            </div>
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className={`flex items-center space-x-2 ${getRoleColor()}`}>
                  {getRoleIcon()}
                  <span className="font-medium capitalize">{profile?.role}</span>
                </div>
                <span className="text-gray-500">|</span>
                <span className="text-gray-700">{profile?.full_name}</span>
              </div>
              <Button variant="outline" size="sm" onClick={handleSignOut}>
                <LogOut className="h-4 w-4 mr-2" />
                Sign Out
              </Button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Welcome back, {profile?.full_name?.split(' ')[0]}!
          </h2>
          <p className="text-gray-600">
            {profile?.role === 'admin' && 'Manage the DisasterPrep Learn platform and monitor all activities.'}
            {profile?.role === 'teacher' && 'Create engaging content and track your students\' progress.'}
            {profile?.role === 'student' && 'Continue your disaster preparedness journey and build life-saving skills.'}
          </p>
        </div>

        {getDashboardContent()}
      </main>
    </div>
  );
};

export default Index;
