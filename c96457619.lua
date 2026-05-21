--エクシーズ・ヴェール
-- 效果：
-- 只要这张卡在场上存在，双方玩家不能把场上表侧表示存在的持有超量素材的超量怪兽作为卡的效果的对象。
function c96457619.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，双方玩家不能把场上表侧表示存在的持有超量素材的超量怪兽作为卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c96457619.etarget)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤出持有超量素材的怪兽（超量素材数量不为0）
function c96457619.etarget(e,c)
	return c:GetOverlayCount()~=0
end
