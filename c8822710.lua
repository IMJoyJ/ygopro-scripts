--A・O・J コズミック・クローザー
-- 效果：
-- 对方场上包含光属性有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
function c8822710.initial_effect(c)
	-- 对方场上包含光属性有怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c8822710.spcon)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的光属性怪兽
function c8822710.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则的判定条件：自身场上有空位，且对方场上怪兽在2只以上，且其中包含光属性怪兽
function c8822710.spcon(e,c)
	if c==nil then return true end
	-- 检查自身场上是否有可以用于特殊召唤的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否在2只以上
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>1
		-- 检查对方场上是否存在至少1只表侧表示的光属性怪兽
		and	Duel.IsExistingMatchingCard(c8822710.spfilter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
