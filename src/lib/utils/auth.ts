import { goto } from '$app/navigation';
import { toast } from 'svelte-sonner';

/**
 * 🦞 先搜 AI - 认证检查工具
 * 检查用户是否已登录，如果未登录则提示并跳转到认证页面
 * @param redirectPath - 认证成功后重定向的路径
 * @returns boolean - 是否已认证
 */
export function requireAuth(redirectPath: string | null = null): boolean {
	const token = localStorage.getItem('token');
	
	if (!token) {
		// 保存当前路径用于认证成功后重定向
		if (redirectPath) {
			localStorage.setItem('redirectPath', redirectPath);
		} else {
			localStorage.setItem('redirectPath', window.location.pathname + window.location.search);
		}
		
		// 提示用户需要登录
		toast.info('请先登录以继续使用', {
			duration: 3000,
			action: {
				label: '去登录',
				onClick: () => {
					goto(`/auth?redirect=${encodeURIComponent(redirectPath || window.location.pathname)}`);
				}
			}
		});
		
		// 延迟跳转到认证页面
		setTimeout(() => {
			goto(`/auth?redirect=${encodeURIComponent(redirectPath || window.location.pathname)}`);
		}, 1500);
		
		return false;
	}
	
	return true;
}

/**
 * 🦞 先搜 AI - 异步认证检查
 * 用于需要等待用户操作的场景
 * @param action - 需要认证的操作描述
 * @returns Promise<boolean> - 是否已认证
 */
export async function checkAuthAsync(action: string = '此操作'): Promise<boolean> {
	const token = localStorage.getItem('token');
	
	if (!token) {
		return new Promise((resolve) => {
			toast.info(`请先登录以${action}`, {
				duration: 5000,
				action: {
					label: '立即登录',
					onClick: () => {
						localStorage.setItem('redirectPath', window.location.pathname + window.location.search);
						goto(`/auth?redirect=${encodeURIComponent(window.location.pathname)}`);
						resolve(false);
					}
				}
			});
			
			// 5 秒后自动跳转
			setTimeout(() => {
				if (!localStorage.getItem('token')) {
					localStorage.setItem('redirectPath', window.location.pathname + window.location.search);
					goto(`/auth?redirect=${encodeURIComponent(window.location.pathname)}`);
					resolve(false);
				}
			}, 5000);
		});
	}
	
	return true;
}
