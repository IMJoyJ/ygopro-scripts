--魂の解放
-- 效果：
-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
function c5758500.initial_effect(c)
	-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5758500.target)
	e1:SetOperation(c5758500.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标选择（Target）函数，用于确认发动条件、选择对象并设置操作信息
function c5758500.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 在发动阶段（chk==0）检查双方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择双方墓地合计1到5张可以除外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置效果处理信息，表明此效果包含除外操作，涉及对象为选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 定义效果处理（Operation）函数，用于执行具体的除外操作
function c5758500.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将满足条件的卡片以表侧表示因效果除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
