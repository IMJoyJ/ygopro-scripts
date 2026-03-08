--野望のゴーファー
-- 效果：
-- 1回合1次，选择对方场上存在的最多2只怪兽才能发动。对方可以把手卡1只怪兽给人观看让这张卡的效果无效。不给观看的场合，选择的怪兽破坏。
function c41224658.initial_effect(c)
	-- 效果原文：1回合1次，选择对方场上存在的最多2只怪兽才能发动。
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
-- 效果作用：选择对方场上存在的1~2只怪兽作为对象。
function c41224658.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果作用：检查是否满足选择对象的条件。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择对方场上的1~2只怪兽作为破坏对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,2,nil)
	-- 效果作用：判断玩家手牌是否全部公开。
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==Duel.GetMatchingGroupCount(Card.IsPublic,tp,0,LOCATION_HAND,nil)
		-- 效果作用：判断玩家手牌中是否存在怪兽卡。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_HAND,1,nil,TYPE_MONSTER) then
		-- 效果作用：设置连锁处理信息，确定破坏效果的处理对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果作用：过滤函数，用于筛选手牌中未公开的怪兽卡。
function c41224658.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
end
-- 效果作用：处理效果发动后的后续流程，包括是否无效效果或进行破坏。
function c41224658.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前连锁是否可以被无效。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 效果作用：获取玩家手牌中未公开的怪兽卡组。
		local cg=Duel.GetMatchingGroup(c41224658.cfilter,tp,0,LOCATION_HAND,nil)
		-- 效果作用：提示对方玩家选择是否将一只怪兽给对方观看。
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(41224658,1))  --"是否要把一只怪兽给对方观看？"
		if cg:GetCount()>0 then
			-- 效果作用：对方选择是否将一只怪兽给对方观看（选项1为观看，选项2为不观看）。
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			-- 效果作用：对方选择是否将一只怪兽给对方观看（选项1为不观看）。
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			-- 效果作用：提示对方玩家选择要确认的怪兽卡。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=cg:Select(1-tp,1,1,nil)
			-- 效果作用：向对方玩家确认所选的怪兽卡。
			Duel.ConfirmCards(tp,sg)
			-- 效果作用：将对方玩家的手牌洗切。
			Duel.ShuffleHand(1-tp)
			-- 效果作用：使当前连锁的效果无效。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 效果作用：获取当前连锁中被选择的破坏对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：将指定对象怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end
