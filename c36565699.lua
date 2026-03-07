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
-- 检查此卡是否从除外区被特殊召唤
function c36565699.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
-- 设置连锁操作信息，表示将要除外1张对方卡组最上方的卡
function c36565699.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK)
end
-- 翻开对方卡组最上方3张卡，选择1张除外，其余返回卡组
function c36565699.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认对方卡组最上方3张卡
	Duel.ConfirmDecktop(1-tp,3)
	-- 获取对方卡组最上方3张卡组成的组
	local g=Duel.GetDecktopGroup(1-tp,3)
	if g:GetCount()>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		-- 将选中的卡除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		-- 将对方卡组洗牌
		Duel.ShuffleDeck(1-tp)
	end
end
