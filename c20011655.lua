--魔剣達士－タルワール・デーモン
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡1回合只有1次不会被对方的效果破坏。
-- ③：只要这张卡在怪兽区域存在，双方不能把其他怪兽作为装备魔法卡的效果的对象。
local s,id,o=GetID()
-- 注册三个效果：①特殊召唤条件、②不被破坏次数、③装备魔法对象限制
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.hspcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡1回合只有1次不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，双方不能把其他怪兽作为装备魔法卡的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0x34,0x34)
	e3:SetTarget(s.tglimit)
	e3:SetValue(s.tgoval)
	c:RegisterEffect(e3)
end
-- 判断特殊召唤条件是否满足：场上没有怪兽且有空位
function s.hspcon(e,c)
	if c==nil then return true end
	-- 判断场上是否没有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断场上是否有空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 设置不被破坏次数为1次（仅对方效果破坏时生效）
function s.indct(e,re,r,rp)
	if r&REASON_EFFECT>0 and e:GetOwnerPlayer()~=rp then
		return 1
	else return 0 end
end
-- 设置装备魔法对象限制的目标条件：不是自身且是怪兽
function s.tglimit(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_MONSTER)
end
-- 设置装备魔法对象限制的值条件：是装备魔法卡
function s.tgoval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsType(TYPE_EQUIP)
end
