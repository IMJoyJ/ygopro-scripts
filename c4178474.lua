--サンダー・ブレイク
-- 效果：
-- ①：丢弃1张手卡，以场上1张卡为对象才能发动。那张卡破坏。
function c4178474.initial_effect(c)
	-- ①：丢弃1张手卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,0x11e0)
	e1:SetCost(c4178474.cost)
	e1:SetTarget(c4178474.target)
	e1:SetOperation(c4178474.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动代价：从手牌丢弃1张卡作为发动条件。
function c4178474.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己手牌中是否存在至少1张可以被丢弃的卡牌，以此判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 支付代价：从手牌中选择1张卡丢弃（丢弃原因记为COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动时的对象选择：选择场上1张卡（不能选择自身）作为对象，并设置破坏的操作信息。
function c4178474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 在对象选择检测阶段，确认场上是否存在至少1张可以作为效果对象的卡（不能选择效果发动者自身）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡作为效果对象（不能选自身），并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的操作信息，标明将破坏所选择的对象，数量为1，供后续效果交互检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时：取得效果对象，若对象仍与效果关联，则将其破坏。
function c4178474.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
