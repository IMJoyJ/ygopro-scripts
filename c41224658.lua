--野望のゴーファー
-- 效果：
-- 1回合1次，选择对方场上存在的最多2只怪兽才能发动。对方可以把手卡1只怪兽给人观看让这张卡的效果无效。不给观看的场合，选择的怪兽破坏。
function c41224658.initial_effect(c)
	-- 1回合1次，选择对方场上存在的最多2只怪兽才能发动。对方可以把手卡1只怪兽给人观看让这张卡的效果无效。不给观看的场合，选择的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41224658,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c41224658.destg)
	e1:SetOperation(c41224658.desop)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理：检查对方场上有可选怪兽，让发动者选择1~2只作为取对象；若对方手牌全部公开且无怪兽，则预先设置破坏操作信息。
function c41224658.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果发动合法性检查：确认对方场上存在至少1只可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动者发送“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者从对方场上选择1~2只怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,2,nil)
	-- 检查对方手牌的数量是否等于其中公开卡的数量，即对方手牌是否全部公开。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==Duel.GetMatchingGroupCount(Card.IsPublic,tp,0,LOCATION_HAND,nil)
		-- 并且检查对方手牌中是否存在怪兽卡；结合上行，若手牌全公开且无怪兽，则对方无法展示手牌怪兽来无效。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_HAND,1,nil,TYPE_MONSTER) then
		-- 设置破坏效果的处理信息：将已选择的怪兽组和数量登记为将被破坏的对象，供后续连锁判断使用。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 定义筛选函数：选择手牌中未公开的怪兽卡，用于检索对方可展示的手牌怪兽。
function c41224658.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
-- 效果处理：若当前效果可被无效，则询问对方是否展示手牌怪兽；选择展示则确认给发动者、洗牌并无效效果；否则继续执行破坏。
function c41224658.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否可以被无效。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手牌中所有未公开的怪兽卡，作为可以选择展示的候选组。
		local cg=Duel.GetMatchingGroup(c41224658.cfilter,tp,0,LOCATION_HAND,nil)
		-- 向对方玩家发送“是否要把一只怪兽给对方观看？”的选择提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(41224658,1))  --"是否要把一只怪兽给对方观看？"
		if cg:GetCount()>0 then
			-- 当有可展示怪兽时，让对方在（是/否）两个选项中选择，返回0或1。
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 当无可展示怪兽时，只显示“否”选项，使选择结果必然为不展示。
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 向对方玩家发送“请选择给对方确认的卡”的提示，要求选择一张手牌怪兽。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=cg:Select(1-tp,1,1,nil)
			-- 将对方选择的展示怪兽展示给发动者确认。
			Duel.ConfirmCards(tp,sg)
			-- 展示后洗切对方手牌，避免因展示暴露手牌顺序信息。
			Duel.ShuffleHand(1-tp)
			-- 使当前连锁的效果无效。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 取得本连锁处理时的对象卡，并过滤出仍与效果相关的卡作为实际破坏对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将过滤后的对象卡用效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
