--虫除けバリアー
-- 效果：
-- 对方场上存在的全部昆虫族的怪兽不能宣言攻击。
function c23615409.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：“对方场上存在的全部昆虫族的怪兽不能宣言攻击。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c23615409.atktarget)
	c:RegisterEffect(e2)
end
-- 该函数是永续效果的目标筛选条件：判断怪兽是否为昆虫族，若为昆虫族则适用“不能攻击宣言”的限制。
function c23615409.atktarget(e,c)
	return c:IsRace(RACE_INSECT)
end
