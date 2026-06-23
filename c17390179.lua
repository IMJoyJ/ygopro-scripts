--閃光の騎士
-- 效果：
-- ←7 【灵摆】 7→
-- 【怪兽描述】
-- 由于神之灵摆而掌握到新力量的骑士。现在是该觉醒过来，解放那股力量了！
function c17390179.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
end
