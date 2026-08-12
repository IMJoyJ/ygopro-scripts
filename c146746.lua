--機関重連アンガー・ナックル
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡不能作为连接素材。
-- ①：自己·对方的主要阶段，把自己的手卡·场上1只怪兽送去墓地，以自己墓地1只机械族·10星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡特殊召唤。
function c146746.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只满足机械族条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：自己·对方的主要阶段，把自己的手卡·场上1只怪兽送去墓地，以自己墓地1只机械族·10星怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(146746,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,146746)
	e1:SetCondition(c146746.spcon1)
	e1:SetCost(c146746.spcost1)
	e1:SetTarget(c146746.sptg1)
	e1:SetOperation(c146746.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己的手卡·场上1张卡送去墓地才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,146746)
	e2:SetCost(c146746.spcost2)
	e2:SetTarget(c146746.sptg2)
	e2:SetOperation(c146746.spop2)
	c:RegisterEffect(e2)
	-- 这张卡不能作为连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：当前阶段为自己的主要阶段1或主要阶段2
function c146746.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的发动费用过滤器：检查手牌或场上的怪兽是否满足送去墓地的条件
function c146746.cfilter1(c,tp)
	-- 过滤器函数：检查目标是否为怪兽、可作为费用送去墓地、且场上存在可用怪兽区
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动费用处理函数
function c146746.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动费用条件：场上有至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c146746.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c146746.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的特殊召唤目标过滤器：检查墓地中的怪兽是否满足机械族且等级为10
function c146746.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动目标选择函数
function c146746.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c146746.spfilter1(chkc,e,tp) end
	-- 检查是否满足发动目标条件：墓地中有至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c146746.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c146746.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将特殊召唤的怪兽数量设为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的发动处理函数
function c146746.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果②的发动费用过滤器：检查手牌或场上的卡是否满足送去墓地的条件
function c146746.cfilter2(c,tp)
	-- 过滤器函数：检查目标是否可作为费用送去墓地、且场上存在可用怪兽区
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动费用处理函数
function c146746.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动费用条件：场上有至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c146746.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c146746.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动目标选择函数
function c146746.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将特殊召唤的卡数量设为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的发动处理函数
function c146746.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
