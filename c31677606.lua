--黒白の波動
-- 效果：
-- 有同调怪兽在作为超量素材中的超量怪兽在场上存在的场合才能发动。选择场上1张卡从游戏中除外，从自己卡组抽1张卡。
function c31677606.initial_effect(c)
	-- 效果原文内容：有同调怪兽在作为超量素材中的超量怪兽在场上存在的场合才能发动。选择场上1张卡从游戏中除外，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c31677606.condition)
	e1:SetTarget(c31677606.target)
	e1:SetOperation(c31677606.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查怪兽是否为超量怪兽且其超量素材中包含同调怪兽
function c31677606.cfilter(c)
	return c:GetOverlayCount()>0 and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 效果作用：判断场上是否存在满足条件的超量怪兽
function c31677606.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否存在满足条件的超量怪兽
	return Duel.IsExistingMatchingCard(c31677606.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果作用：过滤可以除外的卡片
function c31677606.filter(c)
	return c:IsAbleToRemove()
end
-- 效果作用：设置选择目标的过滤条件
function c31677606.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c31677606.filter(chkc) end
	-- 效果作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果作用：检查场上是否存在可除外的卡片
		and Duel.IsExistingTarget(c31677606.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择场上一张可除外的卡片作为效果对象
	local g=Duel.SelectTarget(tp,c31677606.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 效果作用：设置效果处理信息，记录将要除外的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 效果作用：设置效果处理信息，记录将要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果原文内容：有同调怪兽在作为超量素材中的超量怪兽在场上存在的场合才能发动。选择场上1张卡从游戏中除外，从自己卡组抽1张卡。
function c31677606.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断对象卡是否仍然有效且满足除外条件
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 效果作用：让玩家从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
