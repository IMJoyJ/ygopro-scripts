--鉄壁の機皇兵
-- 效果：
-- 只要这张卡在场上存在，自己场上表侧攻击表示存在的名字带有「机皇兵」的怪兽的效果无效化，不会被战斗破坏。
function c59371387.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上表侧攻击表示存在的名字带有「机皇兵」的怪兽的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c59371387.target)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，自己场上表侧攻击表示存在的名字带有「机皇兵」的怪兽...不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c59371387.target)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤出表侧攻击表示且卡名含有「机皇兵」的怪兽作为效果影响对象
function c59371387.target(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSetCard(0x6013)
end
