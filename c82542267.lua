--墓掘りグール
-- 效果：
-- 选择对方的墓地1张到2张的怪兽卡。选择的卡从游戏中除外。
function c82542267.initial_effect(c)
	-- 选择对方的墓地1张到2张的怪兽卡。选择的卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c82542267.target)
	e1:SetOperation(c82542267.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以被除外的怪兽卡
function c82542267.filter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 效果发动的目标选择与操作信息设置
function c82542267.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c82542267.filter(chkc) end
	-- 在发动阶段，检查对方墓地是否存在至少1张满足条件的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c82542267.filter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张到2张满足条件的怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,c82542267.filter,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置操作信息，表示此效果的处理是将选中的卡从对方墓地除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理的执行函数，将选中的对象卡片除外
function c82542267.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡片以表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
