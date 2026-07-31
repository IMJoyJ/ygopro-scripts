--月輪鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次怪兽被战斗·效果破坏，每有1只给这张卡放置1个月轮指示物。
-- ②：可以把这张卡的月轮指示物的以下数量取除，那个效果发动。
-- ●1个：从自己的手卡·墓地把1只6星以下的恶魔族·天使族怪兽特殊召唤。
-- ●3个：从卡组把1只暗属性·10星怪兽加入手卡。
-- ●5个：从自己的手卡·墓地把1只10星怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果，允许放置指示物，并注册了三个效果：一个持续触发的计数器增加效果，以及一个点火效果用于特殊召唤/检索。
function s.initial_effect(c)
	c:EnableCounterPermit(0x74)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建了一个永续、连续的效果，当怪兽被战斗或效果破坏时，给这张卡添加月轮指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- 创建一个点火效果，允许玩家消耗月轮指示物来执行不同的行动（特殊召唤、检索）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x74]=true,
}
-- 定义了用于筛选满足条件的怪兽的过滤函数，检查怪兽是否在场上或墓地，并且是被战斗或效果破坏。
function s.ctfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or
		not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER))
		and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
-- 定义了持续触发效果的条件，检查是否存在被战斗或效果破坏的怪兽。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil)
end
-- 定义了持续触发效果的操作，计算被破坏的怪兽数量并给这张卡添加相应的月轮指示物。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.ctfilter,nil)
	e:GetHandler():AddCounter(0x74,ct)
end
-- 定义了一个过滤函数，用于筛选6星以下的恶魔族/天使族的怪兽，并且可以特殊召唤。
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义了一个过滤函数，用于筛选暗属性10星的怪兽，并且可以加入手牌。
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 定义了一个过滤函数，用于筛选10星的怪兽，并且可以特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义了点火效果的费用处理逻辑，检查玩家是否拥有足够的月轮指示物和满足条件的卡片，并允许玩家选择要执行的操作。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsCanRemoveCounter(tp,0x74,1,REASON_COST)
		-- 检查当前场上是否有空的怪兽区域，用于后续特殊召唤判断。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在符合6星以下恶魔族/天使族的怪兽，用于特殊召唤的条件判断。
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=c:IsCanRemoveCounter(tp,0x74,3,REASON_COST)
		-- 检查卡组中是否存在暗属性10星的怪兽，用于检索的条件判断。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b3=c:IsCanRemoveCounter(tp,0x74,5,REASON_COST)
		-- 检查当前场上是否有空的怪兽区域，用于后续特殊召唤判断。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在10星怪兽，用于特殊召唤的条件判断。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	-- 使用aux.SelectFromOptions函数让玩家选择要执行的操作（特殊召唤、检索）。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"手卡·墓地特殊召唤6星以下怪兽"
			{b2,aux.Stringid(id,2),3},  --"检索暗属性10星怪兽"
			{b3,aux.Stringid(id,3),5})  --"手卡·墓地特殊召10星怪兽"
	c:RemoveCounter(tp,0x74,op,REASON_COST)
	e:SetLabel(op)
end
-- 设置目标卡片的选择条件，如果费用已支付，则检查是否满足特殊召唤或检索的条件。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否存在暗属性10星怪兽。
		and (Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查场上是否有空的怪兽区域。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在符合6星以下恶魔族/天使族的怪兽。
		and (Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查手牌或墓地是否存在10星怪兽。
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)))) end
	local op=e:GetLabel()
	if op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置操作信息，表示将一张卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息，表示特殊召唤一张怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
-- 定义了点火效果的操作逻辑，根据玩家选择的操作执行相应的行动（特殊召唤或检索）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 如果场上没有空的怪兽区域则直接返回，无法进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌和墓地中选择符合条件的怪兽进行特殊召唤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==3 then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择暗属性10星的怪兽加入手牌。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡片送入玩家的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认玩家获得的新卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==5 then
		-- 如果场上没有空的怪兽区域则直接返回，无法进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌和墓地中选择符合条件的10星怪兽进行特殊召唤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 执行特殊召唤操作。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
