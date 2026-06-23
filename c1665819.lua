--レプリカルド・ラッド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡把1只其他的7星以上的怪兽除外才能发动。这张卡特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是等级·攻击力·守备力之内有2个以上相同的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
local s,id,o=GetID()
-- 注册两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从手卡把1只其他的7星以上的怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。和那只怪兽是卡名不同并是等级·攻击力·守备力之内有2个以上相同的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在7星以上且可除外的怪兽
function s.costfilter(c)
	return c:IsLevelAbove(7) and c:IsAbleToRemoveAsCost()
end
-- ①效果的费用处理，选择并除外1只7星以上的怪兽
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的怪兽除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件判断
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果发动时的处理信息，准备特殊召唤自己
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理，将自己特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自己特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断卡组中是否存在满足条件的怪兽
function s.spfilter(c,e,tp,ec)
	if not (not c:IsCode(ec:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	local tr=0
	if c:IsLevel(ec:GetLevel()) then tr=tr+1 end
	if c:IsAttack(ec:GetAttack()) then tr=tr+1 end
	if c:IsDefense(ec:GetDefense()) then tr=tr+1 end
	return tr>1
end
-- 过滤函数，用于判断场上是否存在满足条件的表侧表示怪兽
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
		-- 检查场上是否存在满足条件的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- ②效果的发动条件判断
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,e,tp) end
	-- 判断场上是否有特殊召唤的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的表侧表示怪兽
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上满足条件的表侧表示怪兽
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果发动时的处理信息，准备从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理，选择并特殊召唤符合条件的怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足特殊召唤条件
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc:IsType(TYPE_MONSTER) or not tc:IsRelateToChain() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	-- 将选中的怪兽特殊召唤
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		-- 给特殊召唤的怪兽设置不能发动效果的限制
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
