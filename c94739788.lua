--洗脳解除
-- 效果：
-- 只要这张卡在场上存在，自己与对方场上存在的所有怪兽的控制权回归原本持有者。
function c94739788.initial_effect(c)
	-- 开启全局洗脑解除检查标记，使系统开始检测并处理控制权回归原本持有者的规则
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己与对方场上存在的所有怪兽的控制权回归原本持有者。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e2)
end
