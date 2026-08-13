--メンタルシーカー
-- 效果：
-- 从游戏中除外的这张卡特殊召唤成功时，从对方卡组上面把3张卡翻开，自己从那之中选择1张从游戏中除外，剩下的卡回到卡组。
function c36565699.initial_effect(c)
	-- 从游戏中除外的这张卡特殊召唤成功时，从对方卡组上面把3张卡翻开，自己从那之中选择1张从游戏中除外，剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36565699,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c36565699.condition)
	e1:SetTarget(c36565699.target)
	e1:SetOperation(c36565699.activate)
	c:RegisterEffect(e1)
end
-- 确认这张卡在特殊召唤成功之前位于除外区（即这是从除外区特殊召唤成功的场合）。
function c36565699.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
-- 效果发动时无需额外条件（chk==0直接通过），并设置效果处理时将涉及从卡组除外的操作信息。
function c36565699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次连锁操作包含“除外1张卡组卡”的类别，数量为1，区域为对方卡组。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK)
end
-- 效果结算：依次确认并获取对方卡组最上方3张卡，若存在则提示自己选择其中1张除外，然后洗切对方卡组。
function c36565699.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 把对方卡组最上方3张卡向双方确认（翻开）。
	Duel.ConfirmDecktop(1-tp,3)
	-- 以组对象形式获取对方卡组最上方3张卡。
	local g=Duel.GetDecktopGroup(1-tp,3)
	if g:GetCount()>0 then
		-- 显示“请选择要除外的卡”的选择提示，供接下来从候选卡中选择1张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		-- 将选中的卡以表侧表示除外，除外原因记为“效果”。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 效果处理完成后洗切对方卡组。
		Duel.ShuffleDeck(1-tp)
	end
end
