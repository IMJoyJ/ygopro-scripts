--暗黒の瘴気
-- 效果：
-- 1回合1次，选择对方墓地1只怪兽才能发动。从手卡丢弃1只恶魔族怪兽，选择的怪兽从游戏中除外。
function c41930553.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 效果原文内容：1回合1次，选择对方墓地1只怪兽才能发动。从手卡丢弃1只恶魔族怪兽，选择的怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41930553,1))  --"丢弃手牌并除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(c41930553.target)
	e2:SetOperation(c41930553.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的恶魔族怪兽
function c41930553.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
-- 过滤函数，用于判断对方墓地是否存在可除外的怪兽
function c41930553.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果处理时点，检查是否满足发动条件
function c41930553.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c41930553.rfilter(chkc) end
	-- 检查自己手卡是否存在至少1张恶魔族怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41930553.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查对方墓地是否存在至少1只怪兽
		and Duel.IsExistingTarget(c41930553.rfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c41930553.rfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果发动信息：将要丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置效果发动信息：将要除外1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，执行丢弃手牌和除外怪兽的操作
function c41930553.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张恶魔族怪兽卡丢弃
	local cg=Duel.SelectMatchingCard(tp,c41930553.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if cg:GetCount()==0 then return end
	-- 将选择的恶魔族怪兽卡丢弃至墓地
	Duel.SendtoGrave(cg,REASON_EFFECT+REASON_DISCARD)
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
