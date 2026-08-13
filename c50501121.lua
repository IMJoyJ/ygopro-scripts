--背徳の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。场上1张卡破坏。
function c50501121.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上（表侧表示）把1只「堕天使」怪兽送去墓地才能发动。场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50501121+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c50501121.cost)
	e1:SetTarget(c50501121.target)
	e1:SetOperation(c50501121.activate)
	c:RegisterEffect(e1)
end
-- 判断一张卡是否能作为COST：必须是表侧表示的「堕天使」怪兽，可以作为COST送去墓地，且场上还存在除这张候选卡和本魔法卡以外的卡。
function c50501121.costfilter(c,ec)
	return c:IsSetCard(0xef)
		and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在至少1张除这张COST候选怪兽和本卡（发动卡）以外的卡，以保证破坏效果能有可选择的卡片。
		and Duel.IsExistingMatchingCard(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- COST的完整处理：从自己的手卡·场上（表侧表示）选择1只符合条件的「堕天使」怪兽送去墓地。
function c50501121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认自己手卡·场上是否存在至少1只满足costfilter条件的「堕天使」怪兽可以作为COST送墓。
	if chk==0 then return Duel.IsExistingMatchingCard(c50501121.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,c) end
	-- 向玩家显示选择提示，让其选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡·场上（表侧表示）选择1只符合条件的「堕天使」怪兽作为COST。
	local g=Duel.SelectMatchingCard(tp,c50501121.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,c)
	-- 将选择的「堕天使」怪兽作为COST送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的对象设定：将场上除这张魔法卡以外的所有卡作为可能被破坏的候选，并记录操作信息。
function c50501121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 获取除这张发动卡以外的场上所有卡，作为后续破坏效果的候选集合。
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	if chk==0 then return g:GetCount()>0 end
	-- 设定本次连锁的操作信息：破坏场上的1张卡（候选为场上除自身外的所有卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：从场上选择1张卡破坏（不取对象，在效果处理时选择）。
function c50501121.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 向玩家显示选择提示，让其选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择1张除这张发动卡以外的卡作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
	if g:GetCount()>0 then
		-- 为选择的卡显示选中动画，并将其记录为本次效果的对象。
		Duel.HintSelection(g)
		-- 将选择的卡破坏，破坏原因视为效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
