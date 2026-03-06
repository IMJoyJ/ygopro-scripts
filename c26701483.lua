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
-- 检索满足条件的对方墓地的可除外卡片组
function c26701483.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在满足条件的对方墓地卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张对方墓地的可除外卡片作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本次效果操作信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 处理效果的执行函数
function c26701483.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以正面表示的形式除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
