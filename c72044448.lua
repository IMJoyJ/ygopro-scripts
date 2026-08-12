--破滅のフォトン・ストリーム
-- 效果：
-- 自己场上有名字带有「银河眼」的怪兽存在的场合才能发动。选择场上1张卡从游戏中除外。自己场上没有「银河眼光子龙」存在的场合，这张卡不在自己回合不能发动。
function c72044448.initial_effect(c)
	-- 自己场上有名字带有「银河眼」的怪兽存在的场合才能发动。选择场上1张卡从游戏中除外。自己场上没有「银河眼光子龙」存在的场合，这张卡不在自己回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c72044448.condition)
	e1:SetTarget(c72044448.target)
	e1:SetOperation(c72044448.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「银河眼」怪兽
function c72044448.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x107b)
end
-- 过滤条件：自己场上表侧表示的「银河眼光子龙」
function c72044448.cfilter2(c)
	return c:IsFaceup() and c:IsCode(93717133)
end
-- 发动条件：自己场上有「银河眼」怪兽存在，且必须是自己回合或者自己场上有「银河眼光子龙」存在
function c72044448.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「银河眼」怪兽
	return Duel.IsExistingMatchingCard(c72044448.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前是否为自己回合，或者自己场上是否存在表侧表示的「银河眼光子龙」
		and (Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(c72044448.cfilter2,tp,LOCATION_ONFIELD,0,1,nil))
end
-- 效果发动时的对象选择与操作信息设置
function c72044448.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 发动判定：检查场上是否存在可以被除外的卡（排除自身）
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张可以被除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：除外选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将选中的对象卡除外
function c72044448.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
