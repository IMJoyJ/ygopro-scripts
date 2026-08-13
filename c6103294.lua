--オアシスの使者
-- 效果：
-- 当自己场上存在表侧表示的3星以下的通常怪兽时，对方不能选择这张卡作为攻击对象。当这张卡在自己场上以表侧表示存在时，这张卡的控制者所受到的，由3星以下的通常怪兽进行战斗所造成的战斗伤害为零。
function c6103294.initial_effect(c)
	-- 当自己场上存在表侧表示的3星以下的通常怪兽时，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c6103294.atkcon)
	-- 设置该“不能成为攻击对象”效果的值，使这张卡不对此效果免疫时，对方不能选择这张卡作为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 当这张卡在自己场上以表侧表示存在时，这张卡的控制者所受到的，由3星以下的通常怪兽进行战斗所造成的战斗伤害为零。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetTarget(c6103294.cfilter2)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 由3星以下的通常怪兽进行战斗所造成的战斗伤害为零。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e3:SetTarget(c6103294.cfilter2)
	c:RegisterEffect(e3)
end
-- 攻击限制条件的过滤函数：卡片需为表侧表示、通常怪兽且等级3星以下。
function c6103294.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3)
end
-- 伤害减免效果的过滤函数：卡片需为通常怪兽且等级3星以下，用于指定哪些战斗伤害会被免除。
function c6103294.cfilter2(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3)
end
-- 这张卡不能成为攻击对象的效果的发动条件：自己场上有表侧表示3星以下通常怪兽存在时成立。
function c6103294.atkcon(e)
	-- 检测这张卡的控制者场上是否存在至少1只满足cfilter1的表侧表示3星以下通常怪兽，若存在则返回true，使攻击限制条件成立。
	return Duel.IsExistingMatchingCard(c6103294.cfilter1,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
