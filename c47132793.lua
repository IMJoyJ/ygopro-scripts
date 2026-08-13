--征覇竜－ブレイズ
-- 效果：
-- 7星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上1张卡和对方场上1张卡破坏。
-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到额外卡组。
local s,id,o=GetID()
-- 定义卡的初始化函数：赋予这张卡7阶2素材的XYZ召唤手续与苏生限制，并注册①的破坏效果和②的墓地特殊召唤效果。
function s.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要2只7星怪兽作为超量素材（对应召唤条件‘7星怪兽×2’）。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上1张卡和对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查能否取除这张卡的1个超量素材；可以则实际取除1个超量素材作为发动代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果发动合法性检查：确认自己手卡·场上至少存在1张卡，且对方场上至少存在1张卡，以确保效果处理时能各选1张破坏。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡或场上是否存在至少1张卡（作为破坏对象的备选）。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少1张卡（作为破坏对象的备选）。
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己手卡中的所有卡，用于后续判断自己手卡是否存在卡。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if hg:GetCount()==0 then
		-- 当自己手卡为0时，获取双方场上所有卡，作为破坏候选组（因为自己的破坏对象只能从场上选择）。
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置操作信息：本次破坏效果的处理对象为2张卡，候选范围为双方场上所有卡（用于连锁检测）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	else
		-- 当自己手卡不为0时，获取对方场上所有卡，作为对方场上的破坏对象候选。
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 设置操作信息：本次破坏效果的处理对象为1张卡，对方场上的候选为对方场上所有卡（自己的破坏对象在处理时选择）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- ①效果的处理：从自己手卡·场上选择1张卡，从对方场上选择1张卡，将这两张卡破坏。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认自己手卡·场上仍有卡且对方场上仍有卡，否则效果不处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)>0 and Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 then
		-- 向操作玩家显示选择提示：请选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己手卡·场上的1张卡作为破坏对象。
		local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		-- 再次向操作玩家显示选择提示：请选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡作为破坏对象。
		local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
		-- 为选中的卡显示被选择为对象的动画，并记录这些卡被选为对象。
		Duel.HintSelection(g1)
		-- 以效果原因将选中的卡片破坏。
		Duel.Destroy(g1,REASON_EFFECT)
	end
end
-- 定义②效果除外代价的过滤条件：卡必须是龙族或炎属性，并且可以作为除外代价。
function s.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：从自己手卡·墓地除外2只龙族或炎属性怪兽（不能选择自身）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·墓地中是否存在至少2只符合龙族或炎属性条件、且不是这张卡自身的怪兽作为除外代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 向操作玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手卡·墓地选择2只符合条件的龙族或炎属性怪兽（排除自身）作为除外代价。
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的2张怪兽卡以表侧表示除外作为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判断：确认自己主要怪兽区有空位且这张卡可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格，以及墓地中的这张卡是否满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次处理将使墓地中的这张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将这张卡从墓地特殊召唤，并为其附加‘以此效果特殊召唤的这张卡离场时回到额外卡组’的持续效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时确认这张卡仍与发动效果关联，且主要怪兽区仍有空位，否则不进行特殊召唤。
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区；若特殊召唤成功，则继续附加离场回额外卡组的效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合回到额外卡组。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECK)
		c:RegisterEffect(e1,true)
	end
end
