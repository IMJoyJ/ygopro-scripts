--陽炎獣 グリプス
-- 效果：
-- 对方场上有怪兽存在，自己的场上·墓地没有炎属性以外的怪兽存在的场合，这张卡可以从手卡特殊召唤。只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
function c74010769.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡的效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽存在，自己的场上·墓地没有炎属性以外的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c74010769.spcon)
	c:RegisterEffect(e2)
end
-- 过滤出里侧表示的怪兽以及非炎属性的怪兽
function c74010769.cfilter(c)
	return (c:IsFacedown() or c:IsNonAttribute(ATTRIBUTE_FIRE)) and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件函数：检查怪兽区空位、对方场上怪兽数量以及自己场上·墓地的怪兽属性
function c74010769.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在怪兽
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己的场上和墓地是否不存在非炎属性的怪兽（含里侧表示怪兽）
		and not Duel.IsExistingMatchingCard(c74010769.cfilter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
