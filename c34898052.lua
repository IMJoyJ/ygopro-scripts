--牙竜咆哮
-- 效果：
-- ①：把自己墓地的地·水·炎·风属性怪兽各1只除外才能发动。选场上1张卡回到持有者卡组。
function c34898052.initial_effect(c)
	-- ①：把自己墓地的地·水·炎·风属性怪兽各1只除外才能发动。选场上1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34898052,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c34898052.cost)
	e1:SetTarget(c34898052.target)
	e1:SetOperation(c34898052.activate)
	c:RegisterEffect(e1)
end
-- 为代价检测动态生成四个分别对应地、水、炎、风属性的过滤函数列表，用于检查墓地中每种属性怪兽各1只是否齐备。
c34898052.rchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND})
-- 定义代价用怪兽的筛选条件：必须是地·水·炎·风属性之一的怪兽，并且可以作为代价从墓地除外。
function c34898052.rfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价函数：从墓地获取满足条件的怪兽组，检查是否能选出四种属性各1只；满足则提示玩家选择这些怪兽并以表侧除外作为代价。
function c34898052.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方墓地里满足 rfilter 条件的所有怪兽卡（即可以作为代价的四种属性怪兽）。
	local g=Duel.GetMatchingGroup(c34898052.rfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:CheckSubGroupEach(c34898052.rchecks) end
	-- 给玩家显示选择提示，要求选择要除外的卡（代价素材）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c34898052.rchecks)
	-- 将选中的怪兽卡以表侧表示除外，作为发动效果的代价（REASON_COST）。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 目标判断与操作信息设置：判定能否发动（场上存在可回卡组的卡），并将场上所有可回卡组的卡（除本卡外）作为操作信息登记，表示效果处理时将其中1张返回卡组。
function c34898052.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：场上是否存在至少1张能够返回持有者卡组的卡（且不是发动效果的这张卡），满足则效果可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取场上所有能够返回持有者卡组的卡（不包括发动中的这张卡），供操作信息登记使用。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置操作信息：本连锁效果包含让1张卡返回卡组（CATEGORY_TODECK），g 为可能影响的目标，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数：玩家选择场上1张可返回卡组的卡，将其返回持有者卡组并洗牌；若选择组非空，则进行返回处理。
function c34898052.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，要求选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从场上（双方区域）选择1张能够返回持有者卡组的卡，排除发动效果的这张卡（若仍在场上且与效果相关）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 手动显示选中的卡作为效果对象的动画，并记录其为该连锁的对象。
		Duel.HintSelection(g)
		-- 将选中的卡返回持有者卡组（player=nil 表示由持有者决定），指定返回卡组后洗牌，原因记为效果（REASON_EFFECT）。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
