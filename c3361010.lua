--愉怪な燐のきつねびゆらら
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成炎属性。
-- ②：这张卡在墓地存在，对方的场上或者墓地有炎属性怪兽存在的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①改变场上怪兽属性为炎属性；②墓地发动特殊召唤效果
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成炎属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，对方的场上或者墓地有炎属性怪兽存在的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检测场上或墓地是否存在表侧表示的炎属性怪兽
function s.filter(c)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 条件函数，判断是否满足发动效果的条件（对方场上有炎属性怪兽）
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或墓地是否存在至少1只表侧表示的炎属性怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- 目标函数，判断是否可以发动特殊召唤效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的召唤区域以及该卡是否可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，确定特殊召唤的目标卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认该卡与效果有关联后进行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
