--電光－雪花－
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡在怪兽区域存在，自己场上没有盖放的魔法·陷阱卡存在的场合，双方不能把魔法·陷阱卡盖放，场上盖放的魔法·陷阱卡不能发动。
function c13974207.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 自己场上没有盖放的魔法·陷阱卡存在的场合，双方不能把魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c13974207.effcon)
	c:RegisterEffect(e2)
	-- 场上盖放的魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c13974207.distg)
	e3:SetCondition(c13974207.effcon)
	c:RegisterEffect(e3)
end
-- 效果作用：判断是否己方场上存在里侧表示的魔法·陷阱卡。
function c13974207.effcon(e)
	-- 效果作用：检查己方魔法·陷阱区域是否存在里侧表示的卡。
	return not Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
-- 效果作用：目标卡为里侧表示的魔法·陷阱卡。
function c13974207.distg(e,c)
	return c:IsFacedown()
end
