--愉怪な燐のきつねびゆらら
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成炎属性。
-- ②：这张卡在墓地存在，对方的场上或者墓地有炎属性怪兽存在的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 卡片效果注册入口：创建并注册两个效果，①为永续领域效果（全场表侧怪兽变炎属性），②为墓地发动的起动效果（特殊召唤自身并受1回合1次限制）。
function s.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成炎属性。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，对方的场上或者墓地有炎属性怪兽存在的场合才能发动。这张卡特殊召唤。
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
-- 定义过滤器：检查卡片是否满足表侧表示（或处于公开区域）且属性为炎属性，用于筛选对方场上或墓地存在的炎属性怪兽。
function s.filter(c)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- ②效果的发动条件：对方场上或墓地存在至少1张满足s.filter条件的炎属性怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上或墓地是否存在至少1张表侧表示且炎属性的怪兽。
	return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end
-- ②效果的发动目标处理：获取效果持有者（墓地中的这张卡），在发动时确认自己主要怪兽区有空位且这张卡可以被特殊召唤。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 如果是发动时的合法性检查，则要求自己场上的主要怪兽区域存在可用空格，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：这次效果处理包含特殊召唤，处理对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理时的实际操作：获取效果持有者，若该卡仍与本次效果保持关联，则将其表侧表示特殊召唤到自己场上。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与发动时建立联系的效果对象（即仍可被处理），若是则将其特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
