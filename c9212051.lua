--SPYRAL MISSION－救出
-- 效果：
-- 这张卡发动后，第3次的自己结束阶段破坏。
-- ①：「秘旋谍任务-救出」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，以自己墓地1只「秘旋谍」怪兽为对象才能发动。那只怪兽加入手卡。
-- ③：把墓地的这张卡除外，以自己墓地1只「秘旋谍」怪兽为对象才能发动。那只怪兽特殊召唤。
function c9212051.initial_effect(c)
	c:SetUniqueOnField(1,0,9212051)
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(9212051,0))  --"发动但不使用效果"
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	e0:SetTarget(c9212051.target)
	c:RegisterEffect(e0)
	-- ②：1回合1次，以自己墓地1只「秘旋谍」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9212051,1))  --"发动并使用效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c9212051.thcost)
	e1:SetTarget(c9212051.thtg1)
	e1:SetOperation(c9212051.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c9212051.thtg2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己墓地1只「秘旋谍」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9212051,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置把墓地的这张卡除外作为发动效果的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c9212051.sptg)
	e3:SetOperation(c9212051.spop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理，注册在第3个自己结束阶段将自身破坏的延迟效果
function c9212051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第3次的自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c9212051.descon)
	e1:SetOperation(c9212051.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
	c:SetTurnCounter(0)
	c:RegisterEffect(e1)
end
-- 判断当前回合玩家是否为自身控制者，作为结束阶段破坏效果的触发条件
function c9212051.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段破坏效果的执行操作，累加回合计数器并在达到3次时破坏这张卡
function c9212051.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 因规则原因破坏这张卡
		Duel.Destroy(c,REASON_RULE)
	end
end
-- 回收效果的发动代价，确保同一张卡在发动回合及后续回合共用1次发动机会
function c9212051.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(9212051)==0 end
	e:GetHandler():RegisterFlagEffect(9212051,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤自己墓地中可以加入手牌的「秘旋谍」怪兽
function c9212051.thfilter(c)
	return c:IsSetCard(0xee) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 卡片发动并同时使用回收效果时的目标选择与操作信息设置，并注册自身破坏的延迟效果
function c9212051.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9212051.thfilter(chkc) end
	-- 判断自己墓地是否存在可以加入手牌的「秘旋谍」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9212051.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「秘旋谍」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9212051.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	c9212051.target(e,tp,eg,ep,ev,re,r,rp,1)
end
-- 已在场上表侧表示存在的这张卡发动回收效果时的目标选择与操作信息设置
function c9212051.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9212051.thfilter(chkc) end
	-- 判断自己墓地是否存在可以加入手牌的「秘旋谍」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9212051.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「秘旋谍」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9212051.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行操作，将作为对象的怪兽加入手牌
function c9212051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤自己墓地中可以特殊召唤的「秘旋谍」怪兽
function c9212051.spfilter(c,e,tp)
	return c:IsSetCard(0xee) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择与操作信息设置
function c9212051.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c9212051.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在可以特殊召唤的「秘旋谍」怪兽
		and Duel.IsExistingTarget(c9212051.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「秘旋谍」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9212051.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果的处理为特殊召唤选中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行操作，将作为对象的怪兽特殊召唤
function c9212051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
