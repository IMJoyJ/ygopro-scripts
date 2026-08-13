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
	-- 设置效果值为aux.imval1函数：该函数判定卡片是否对此效果免疫，若免疫则不允许成为攻击对象，否则允许。
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
-- 定义过滤函数cfilter：用于判断卡片是否为表侧表示且拥有「自然」字段（0x2a）。
function c17285476.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 定义发动条件atcon：检查自己场上是否存在除本卡以外满足cfilter（表侧且「自然」）的怪兽，若存在则本卡获得“不能成为攻击对象”的适用条件。
function c17285476.atcon(e)
	-- 调用Duel.IsExistingMatchingCard，确认在自己怪兽区、除本卡之外，是否存在至少1张表侧表示且字段为「自然」的怪兽。
	return Duel.IsExistingMatchingCard(c17285476.cfilter,e:GetOwnerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义伤害代受对象过滤函数reftg：卡片需满足不是本卡、表侧表示且字段为「自然」，即“这张卡以外的自己场上表侧表示存在的名字带有「自然」的怪兽”的判定条件。
function c17285476.reftg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x2a)
end
