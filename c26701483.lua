--カードエクスクルーダー
-- 效果：
-- 选择对方墓地存在的1张卡从游戏中除外。这个效果1回合只能使用1次。
function c26701483.initial_effect(c)
	-- 选择对方墓地存在的1张卡从游戏中除外。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26701483,0))  --"对方墓地存在的1张卡从游戏中除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c26701483.rmtg)
	e1:SetOperation(c26701483.rmop)
	c:RegisterEffect(e1)
end
-- 效果的发动时点与目标选择处理函数：确认能否选择对方墓地的卡，提示并让玩家选择1张符合条件的卡作为对象，同时设置除外相关的操作信息。
function c26701483.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 在发动时检查对方墓地是否存在至少1张可以被除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向当前玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1张可以被除外的卡，并将其登记为本次效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁的操作信息：将对象卡从对方墓地除外，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理函数：取得已选择的目标，确认其仍与效果关联后将其除外。
function c26701483.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡以表侧表示从游戏中除外，除外原因记为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
