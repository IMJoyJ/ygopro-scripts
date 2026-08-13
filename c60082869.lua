--砂塵の大竜巻
-- 效果：
-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从手卡把1张魔法·陷阱卡盖放。
function c60082869.initial_effect(c)
	-- ①：以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从手卡把1张魔法·陷阱卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c60082869.target)
	e1:SetOperation(c60082869.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：选择场上的魔法·陷阱卡作为可对象候选。
function c60082869.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择处理：确认对象为对方场上的魔法·陷阱卡，选择1张作为对象，并登记破坏的操作信息。
function c60082869.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c60082869.filter(chkc) end
	-- 检查是否存在合法对象：对方场上是否有1张魔法·陷阱卡（且不是本卡）可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c60082869.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 发出“请选择要破坏的卡”的提示消息，用于引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张魔法·陷阱卡作为效果对象，并将其设为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,c60082869.filter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记破坏效果的操作信息：确定要破坏1张对象卡，供后续时点检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：先破坏对象卡；若破坏成功，则询问并选择手牌1张魔法陷阱卡盖放到场上。
function c60082869.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的对象卡（即发动时选择的那张对方魔法陷阱卡）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上且与效果相关，则将其破坏；破坏成功时才继续后续盖放处理。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 获取自己手牌中所有可以盖放的魔法·陷阱卡，作为可选盖放集合。
		local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 若存在可盖放的卡，则询问玩家是否要盖放，并弹出对应的确认提示。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(60082869,0)) then  --"是否要放置魔法或陷阱卡？"
			-- 调用BreakEffect将后续盖放处理与之前的破坏处理分为不同时点，避免错过时点。
			Duel.BreakEffect()
			-- 发出“请选择要盖放的卡”的提示消息，用于引导玩家选择手牌中要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的手牌中的1张魔法陷阱卡盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
