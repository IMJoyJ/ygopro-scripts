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
	-- ①：这张卡在怪兽区域存在，自己场上没有盖放的魔法·陷阱卡存在的场合，双方不能把魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c13974207.effcon)
	c:RegisterEffect(e2)
	-- ①：这张卡在怪兽区域存在，自己场上没有盖放的魔法·陷阱卡存在的场合，场上盖放的魔法·陷阱卡不能发动。
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
-- 定义效果适用条件：这张卡在怪兽区域存在，且我方场上不存在里侧表示的魔法·陷阱卡时，该效果才适用。
function c13974207.effcon(e)
	-- 检查以当前效果控制者视角的自己魔法与陷阱区域（含场地区）是否存在里侧表示的魔法·陷阱卡；若不存在则返回 true，即满足“自己场上没有盖放的魔法·陷阱卡”这一条件。
	return not Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
-- 定义效果对象筛选函数：只对里侧表示的魔法·陷阱卡（即场上盖放的魔陷）适用，用于禁止其发动。
function c13974207.distg(e,c)
	return c:IsFacedown()
end
