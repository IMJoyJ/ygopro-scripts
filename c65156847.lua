--ネオフレムベル・ガルーダ
-- 效果：
-- 自己的结束阶段时，这张卡以外的名字带有「炎狱」的怪兽在自己场上表侧表示存在的场合，选择对方墓地存在的1张卡从游戏中除外。
function c65156847.initial_effect(c)
	-- 自己的结束阶段时，这张卡以外的名字带有「炎狱」的怪兽在自己场上表侧表示存在的场合，选择对方墓地存在的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65156847,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c65156847.rmcon)
	e1:SetTarget(c65156847.rmtg)
	e1:SetOperation(c65156847.rmop)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的名字带有「炎狱」的怪兽
function c65156847.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2c)
end
-- 发动条件：自己的结束阶段，且自己场上存在这张卡以外的表侧表示「炎狱」怪兽
function c65156847.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 判断自己场上是否存在至少1张这张卡以外的表侧表示「炎狱」怪兽
		and Duel.IsExistingMatchingCard(c65156847.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果的目标选择：选择对方墓地存在的1张卡作为对象
function c65156847.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 在客户端显示提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地存在的1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将对方墓地的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：将选择的对象卡片除外
function c65156847.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
