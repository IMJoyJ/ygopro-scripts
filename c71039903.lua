--太古の白石
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只「青眼」怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「青眼」怪兽为对象才能发动。那只怪兽加入手卡。
function c71039903.initial_effect(c)
	-- ①：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只「青眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c71039903.regop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「青眼」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71039903,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,71039903)
	-- 设置把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c71039903.target)
	e2:SetOperation(c71039903.operation)
	c:RegisterEffect(e2)
end
-- 注册在送去墓地的回合的结束阶段可以发动的特殊召唤效果
function c71039903.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只「青眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71039903,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(c71039903.sptg)
	e1:SetOperation(c71039903.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以特殊召唤的「青眼」怪兽
function c71039903.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测
function c71039903.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「青眼」怪兽
		and Duel.IsExistingMatchingCard(c71039903.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行函数
function c71039903.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「青眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c71039903.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤墓地中可以加入手牌的「青眼」怪兽
function c71039903.filter(c)
	return c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 回收效果的发动准备与目标选择
function c71039903.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c71039903.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在可以加入手牌的「青眼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c71039903.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「青眼」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c71039903.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理中的操作信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的执行函数
function c71039903.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的回收对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
	end
end
