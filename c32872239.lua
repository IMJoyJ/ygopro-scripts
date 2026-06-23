--ガルガルドの屍煉魔
-- 效果：
-- ←9 【灵摆】 9→
-- 【怪兽描述】
-- 身披摇荡之炎，能变一切他者之貌的鸟魔人。从鸟到人、从人到鸟反复变化的过程中，就这么遗忘了本来的自己。
local s,id,o=GetID()
-- 注册灵摆怪兽的相关效果
function s.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
end
