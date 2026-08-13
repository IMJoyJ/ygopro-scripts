--地下牢の徊神
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡从卡组送去墓地的场合发动（双方不能对应这个效果的发动把怪兽的效果发动）。自己场上的卡全部送去墓地，这张卡特殊召唤。那之后，把最多有这个效果送去墓地的卡数量的对方场上的卡送去墓地。
-- ②：这张卡从卡组以外送去墓地的场合，把1张手卡送去墓地才能发动。场上1张卡送去墓地。
local s,id,o=GetID()
-- 创建并注册此卡的两个诱发效果，它们对应“这个卡名的①②的效果1回合只能有1次使用其中任意1个。”的共享1回合1次限制：①从卡组送去墓地时必发，清自己全场后特殊召唤并追加送对方场上的卡；②从卡组以外送去墓地时选发，丢弃1张手卡后选场上1张卡送去墓地。
function s.initial_effect(c)
	-- ①：这张卡从卡组送去墓地的场合发动（双方不能对应这个效果的发动把怪兽的效果发动）。自己场上的卡全部送去墓地，这张卡特殊召唤。那之后，把最多有这个效果送去墓地的卡数量的对方场上的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组以外送去墓地的场合，把1张手卡送去墓地才能发动。场上1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送墓效果"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- ①效果发动条件：判定此卡被送去墓地之前所在位置是卡组，即从卡组被送入墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- ①效果发动时处理：登记要清空自己场上所有卡以及特殊召唤本卡的操作信息，并设置本连锁中禁止对方连锁发动怪兽效果。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上全部卡（怪兽区域和魔法陷阱区域）作为即将被“全部送去墓地”的对象集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 登记以卡组形式记录的即将被送去墓地的自己场上全部卡及其数量，用于后续效果处理与检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,sg:GetCount(),0,0)
	-- 登记这次效果中本卡将要特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁限制，使双方在本次效果发动后不能随意连锁发动指定以外的效果（具体限制由s.climit判定）。
	Duel.SetChainLimit(s.climit)
end
-- 连锁限制判定：被连锁尝试发动的效果若由怪兽卡发动（即其效果来源是怪兽），则不允许连锁；从而达成“双方不能对应这个效果的发动把怪兽的效果发动”。
function s.climit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_MONSTER)
end
-- ①效果处理：先将自己场上所有卡送去墓地；若确有卡被送入墓地，则统计其中现在仍在墓地的数量；若本卡仍与效果关联且能成功表侧表示特殊召唤，并且对方场上有可送墓的卡，则用BreakEffect制造时点，再从对方场上选择最多为该数量的卡送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上全部卡作为要送去墓地的集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,nil)
	-- 以“效果”为原因将自己场上全部卡送去墓地，并判断实际送入墓地数量不为0时才继续后续处理。
	if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 then
		-- 取得刚才这次送入墓地操作实际被处理到的卡组，用于统计送入数量。
		local g=Duel.GetOperatedGroup()
		local ct=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetCount()
		-- 条件判断：实际送入墓地的卡数ct不为0，且本卡与发动中的效果仍有联系，且本卡能够表侧表示特殊召唤成功（返回值非0）。
		if ct~=0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 追加条件：对方场上有至少1张可送去墓地的卡，才执行后续的选卡送墓。
			and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) then
			-- 中断当前效果链，使之后的追加送墓处理与前一段处理分开结算，避免卡在时点上导致不能正确发动/处理后续效果。
			Duel.BreakEffect()
			-- 向当前玩家显示选择提示，提示内容为“请选择要送去墓地的卡”（用于选择卡时的对话框）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从对方场上选择1到ct张（ct为之前实际送入墓地的卡数）可送去墓地的卡，作为追加送去墓地的对象。
			local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,ct,nil)
			-- 手动显示这些被选中的卡的选中动画，并记录它们已作为本次效果的对象。
			Duel.HintSelection(tg)
			-- 将选择的对方场上的卡以“效果”原因送去墓地，完成“那之后”的追加送墓处理。
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end
-- ②效果发动条件：判定此卡被送去墓地之前所在位置不是卡组，即从卡组以外的地方被送入墓地。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- ②效果的发动代价：从手卡选择1张卡送去墓地作为COST；只有能支付该代价才能发动。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：手牌中是否存在1张除本卡以外可送去墓地作为COST的卡（存在则满足支付条件）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 显示选择提示，提示玩家选择要送去墓地的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1张可送去墓地作为COST的卡，作为代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡以“COST”原因送去墓地，完成代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果发动时处理：确认场上（双方怪兽区/魔陷区）存在可送去墓地的卡，并登记将要从场上选1张卡送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：双方场上是否存在至少1张可送去墓地的卡，存在才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 登记效果处理时将从场上选择1张卡送去墓地的操作信息（不取对象，targets为nil，数量为1，位置限定为场上）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
-- ②效果处理：从双方场上选择1张可送去墓地的卡，将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从双方场上选择1张可送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中动画并记录这张卡已作为本次效果的对象。
		Duel.HintSelection(g)
		-- 将选择的卡以“效果”原因送去墓地，完成送墓处理。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
