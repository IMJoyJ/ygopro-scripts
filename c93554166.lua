--暗黒界の雷
-- 效果：
-- ①：以场上盖放的1张卡为对象才能发动。那张盖放的卡破坏。那之后，选自己1张手卡丢弃。
function c93554166.initial_effect(c)
	-- ①：以场上盖放的1张卡为对象才能发动。那张盖放的卡破坏。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c93554166.target)
	e1:SetOperation(c93554166.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：里侧表示（盖放）的卡片
function c93554166.filter(c)
	return c:IsFacedown()
end
-- 效果发动时的对象选择与可行性检查
function c93554166.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c93554166.filter(chkc) end
	-- 检查场上是否存在可以作为对象的里侧表示卡片
	if chk==0 then return Duel.IsExistingTarget(c93554166.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 检查自己手牌中是否存在至少1张卡（排除当前发动的卡）
		and Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_HAND,0,e:GetHandler())>0 end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张里侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c93554166.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：破坏对象卡片，之后丢弃1张手牌
function c93554166.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 因效果将该卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
		-- 检查自己手牌数量是否大于0
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
			-- 中断效果处理，使破坏和丢弃手牌不视为同时进行（满足“那之后”的时点要求）
			Duel.BreakEffect()
			-- 玩家选择自己1张手牌丢弃
			Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
