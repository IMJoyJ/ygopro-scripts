--グラディアル・チェンジ
-- 效果：
-- 自己场上有名字带有「剑斗兽」的怪兽特殊召唤时才能发动。对方选择1张手卡丢弃。
function c97234686.initial_effect(c)
	-- 自己场上有名字带有「剑斗兽」的怪兽特殊召唤时才能发动。对方选择1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c97234686.condition)
	e1:SetTarget(c97234686.target)
	e1:SetOperation(c97234686.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且卡名带有「剑斗兽」的怪兽
function c97234686.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x1019)
end
-- 发动条件：特殊召唤成功的怪兽中存在满足过滤条件的怪兽
function c97234686.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97234686.filter,1,nil,tp)
end
-- 效果的目标处理：确认对方手卡数量并设置丢弃手卡的操作信息
function c97234686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，确认对方手卡数量至少有1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置操作信息：丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：执行对方丢弃手卡的操作
function c97234686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方选择1张手卡因效果丢弃
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_DISCARD+REASON_EFFECT)
end
