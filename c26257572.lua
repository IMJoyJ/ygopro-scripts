--苦痛の回廊
-- 效果：
-- 只要这张卡在场上存在，从卡组特殊召唤的怪兽只要在场上表侧表示存在效果不能发动并无效化，也不能攻击宣言。
function c26257572.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 从卡组特殊召唤的怪兽只要在场上表侧表示存在效果不能发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c26257572.actlimit)
	c:RegisterEffect(e2)
	-- 并无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c26257572.target)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e4)
end
-- 判断要发动的效果是否来自从卡组特殊召唤且在场上存在的怪兽，若是则禁止其发动（对应“效果不能发动”）
function c26257572.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsOnField() and rc:IsSummonLocation(LOCATION_DECK)
end
-- 判断怪兽是否是从卡组特殊召唤而来，用于将这类怪兽作为无效化/不能攻击宣言的对象
function c26257572.target(e,c)
	return c:IsSummonLocation(LOCATION_DECK)
end
