--ロスト
-- 效果：
-- 选择对方墓地的1张卡从游戏中除外。
function c24623598.initial_effect(c)
	-- 选择对方墓地的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24623598.target)
	e1:SetOperation(c24623598.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的取对象处理：先处理连锁指定对象的情况，再确认是否存在合法对象；若满足则提示玩家选择对方墓地1张可除外的卡作为对象，并设置将对象卡除外的操作信息。
function c24623598.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 发动条件判定：检查对方墓地是否存在至少1张能够被除外的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向发动玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地中选择1张能够被除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁的操作信息：将所选择的对象卡从墓地除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理时的操作：取出效果对象卡，若对象卡仍与效果关联，则将其从游戏中除外。
function c24623598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象卡（取对象效果处理时的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外（因卡片效果而除外）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
