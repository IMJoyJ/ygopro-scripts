--太陽の祭壇
-- 效果：
-- 只要这张卡在场上存在，自己场上表侧表示存在的从墓地特殊召唤的怪兽的攻击力上升300。
function c91468551.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上表侧表示存在的从墓地特殊召唤的怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c91468551.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
-- 过滤出特殊召唤自墓地的怪兽作为攻击力上升效果的影响对象
function c91468551.atktg(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsSummonLocation(LOCATION_GRAVE)
end
