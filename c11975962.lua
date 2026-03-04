--抹殺の聖刻印
-- 效果：
-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。选择对方场上1张卡从游戏中除外。
function c11975962.initial_effect(c)
	-- 效果原文内容：把自己场上1只名字带有「圣刻」的怪兽解放才能发动。选择对方场上1张卡从游戏中除外。
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
-- 检查是否满足解放条件并选择解放的怪兽
function c11975962.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在至少1只名字带有「圣刻」的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x69) end
	-- 选择1只名字带有「圣刻」的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x69)
	-- 将选中的怪兽从场上解放，作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标选择函数
function c11975962.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 确认对方场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择对方场上1张可除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时的操作信息，确定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 设置效果的发动处理函数
function c11975962.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
