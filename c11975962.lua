--抹殺の聖刻印
-- 效果：
-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。选择对方场上1张卡从游戏中除外。
function c11975962.initial_effect(c)
	-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。选择对方场上1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c11975962.cost)
	e1:SetTarget(c11975962.target)
	e1:SetOperation(c11975962.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价：从自己场上选择并解放1只名字带有「圣刻」的怪兽。
function c11975962.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1只以上名字带有「圣刻」的可解放怪兽（作为发动代价）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x69) end
	-- 从自己场上选择1只名字带有「圣刻」的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x69)
	-- 解放选择的怪兽，作为此效果的发动代价。
	Duel.Release(g,REASON_COST)
end
-- 为效果选择对象：选择对方场上1张能够被除外的卡作为此效果的对象。
function c11975962.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在1张以上能够被除外的卡（能够成为此效果对象的卡）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张能够被除外的卡作为此效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置此连锁的操作信息：类别为除外，对象为选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将作为对象的那张卡从游戏中除外。
function c11975962.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
