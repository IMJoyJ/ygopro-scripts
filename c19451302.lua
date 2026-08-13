--スネーク・チョーク
-- 效果：
-- 对方场上表侧攻击表示存在的攻击力是0的怪兽不会被和名字带有「爬虫妖」的怪兽的战斗破坏。
function c19451302.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上表侧攻击表示存在的攻击力是0的怪兽不会被和名字带有「爬虫妖」的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c19451302.indtg)
	-- 设置效果值为过滤器，检查战斗对象是否属于「爬虫妖」系列（0x3c），即仅当与「爬虫妖」怪兽进行战斗时，目标怪兽才适用此战斗破坏免疫。
	e2:SetValue(aux.TargetBoolFunction(Card.IsSetCard,0x3c))
	c:RegisterEffect(e2)
end
-- 目标筛选函数：仅当怪兽是攻击力为0且表侧攻击表示时才成为该效果的适用对象，即对应原文中“对方场上表侧攻击表示存在的攻击力是0的怪兽”。
function c19451302.indtg(e,c)
	return c:IsAttack(0) and c:IsAttackPos()
end
