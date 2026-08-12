--Kozmo－ドッグファイター
-- 效果：
-- ①：自己·对方的准备阶段才能发动。在自己场上把1只「DOG战斗机衍生物」（机械族·暗·6星·攻2000/守2400）特殊召唤。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
function c29491334.initial_effect(c)
	-- ①：自己·对方的准备阶段才能发动。在自己场上把1只「DOG战斗机衍生物」（机械族·暗·6星·攻2000/守2400）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29491334,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetTarget(c29491334.tktg)
	e1:SetOperation(c29491334.tkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29491334,1))  --"从卡组把「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c29491334.spcon)
	e2:SetCost(c29491334.spcost)
	e2:SetTarget(c29491334.sptg)
	e2:SetOperation(c29491334.spop)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤衍生物的条件
function c29491334.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,29491335,0,TYPES_TOKEN_MONSTER,2000,2400,6,RACE_MACHINE,ATTRIBUTE_DARK) end
	-- 设置操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行特殊召唤衍生物的操作
function c29491334.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,29491335,0,TYPES_TOKEN_MONSTER,2000,2400,6,RACE_MACHINE,ATTRIBUTE_DARK) then return end
	-- 创建指定的衍生物卡片
	local token=Duel.CreateToken(tp,29491335)
	-- 将创建的衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断此卡是否因战斗或效果破坏而进入墓地
function c29491334.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 设置发动效果的费用：将此卡从墓地除外
function c29491334.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将此卡从墓地除外作为费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义用于筛选「星际仙踪」怪兽的过滤函数
function c29491334.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足特殊召唤「星际仙踪」怪兽的条件
function c29491334.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c29491334.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：将要从卡组特殊召唤「星际仙踪」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组特殊召唤「星际仙踪」怪兽的操作
function c29491334.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c29491334.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
