--ナチュル・モスキート
-- 效果：
-- 只要自己场上有这张卡以外的名字带有「自然」的怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。这张卡以外的自己场上表侧表示存在的名字带有「自然」的怪兽的战斗发生的对自己的战斗伤害由对方代受。
function c17285476.initial_effect(c)
	-- 只要自己场上有这张卡以外的名字带有「自然」的怪兽表侧表示存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c17285476.atcon)
	-- 设置效果值为aux.imval1函数，用于判断目标是否不能成为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这张卡以外的自己场上表侧表示存在的名字带有「自然」的怪兽的战斗发生的对自己的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c17285476.reftg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断一张卡是否是表侧表示且名字带有「自然」。
function c17285476.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 条件函数，用于判断自己场上是否存在除这张卡外的表侧表示的「自然」怪兽。
function c17285476.atcon(e)
	-- 检查以效果拥有者为玩家，在自己的主要怪兽区是否存在至少1张满足cfilter条件且不等于效果处理卡的卡。
	return Duel.IsExistingMatchingCard(c17285476.cfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 目标过滤函数，用于判断一张卡是否不是效果处理卡且是表侧表示且名字带有「自然」。
function c17285476.reftg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x2a)
end
