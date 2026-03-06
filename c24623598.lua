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
-- 检查选择目标时是否满足条件：对方墓地的卡且可以除外
function c24623598.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 判断是否满足发动条件：对方墓地存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 处理效果：将选中的卡从游戏中除外
function c24623598.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以正面表示形式从游戏中除外，原因效果
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
