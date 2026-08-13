--黒白の波動
-- 效果：
-- 有同调怪兽在作为超量素材中的超量怪兽在场上存在的场合才能发动。选择场上1张卡从游戏中除外，从自己卡组抽1张卡。
function c31677606.initial_effect(c)
	-- 有同调怪兽在作为超量素材中的超量怪兽在场上存在的场合才能发动。选择场上1张卡从游戏中除外，从自己卡组抽1张卡。
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
-- 判定超量怪兽是否持有超量素材，且其超量素材中是否存在同调怪兽。
function c31677606.cfilter(c)
	return c:GetOverlayCount()>0 and c:GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
-- 发动条件判定：从双方主要怪兽区检查是否存在至少1只满足“有同调怪兽作为超量素材的超量怪兽”条件的怪兽。
function c31677606.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上是否存在满足条件的超量怪兽。
	return Duel.IsExistingMatchingCard(c31677606.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 对象选择用过滤函数：判定卡片是否可以被除外。
function c31677606.filter(c)
	return c:IsAbleToRemove()
end
-- 发动时的目标处理：确认自己可以抽卡且场上存在可除外的对象；选择目标时，从双方场上选择1张卡作为效果对象。
function c31677606.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c31677606.filter(chkc) end
	-- 效果发动合法性检查：确认自己玩家可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果发动合法性检查：确认场上存在可作为效果对象且能够被除外的卡（排除发动效果的这张卡自身）。
		and Duel.IsExistingTarget(c31677606.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 选择要除外的卡时，向玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从场上选择1张可除外的卡作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c31677606.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：本次效果将除外1张已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次效果使自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：取得对象卡，若对象仍与效果关联则将其表侧表示除外；除外成功后，自己从卡组抽1张卡。
function c31677606.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且能够被除外；若将其表侧表示除外成功，则继续处理。
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
