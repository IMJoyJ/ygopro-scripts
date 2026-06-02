--月輪鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次怪兽被战斗·效果破坏，每有1只给这张卡放置1个月轮指示物。
-- ②：可以把这张卡的月轮指示物的以下数量取除，那个效果发动。
-- ●1个：从自己的手卡·墓地把1只6星以下的恶魔族·天使族怪兽特殊召唤。
-- ●3个：从卡组把1只暗属性·10星怪兽加入手卡。
-- ●5个：从自己的手卡·墓地把1只10星怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableCounterPermit(0x74)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次怪兽被战斗·效果破坏，每有1只给这张卡放置1个月轮指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：可以把这张卡的月轮指示物的以下数量取除，那个效果发动。
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
-- 判定怪兽是否在场上被战斗或效果破坏的过滤函数
function s.ctfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or
		not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER))
		and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
-- 判断是否有满足条件的怪兽被破坏以触发放置指示物的效果条件
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil)
end
-- 效果①（被破坏时放置指示物）的效果处理函数，根据被破坏的怪兽数量为这张卡放置对应数量的月轮指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.ctfilter,nil)
	e:GetHandler():AddCounter(0x74,ct)
end
-- 过滤手卡·墓地中等级6以下的恶魔族或天使族怪兽的特殊召唤条件
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中暗属性·等级10怪兽的检索条件
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 过滤手卡·墓地中等级10怪兽的特殊召唤条件
function s.spfilter2(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（去除指示物选择发动对应效果）的发动代价与选项选择函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsCanRemoveCounter(tp,0x74,1,REASON_COST)
		-- 且当前玩家场上存在可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手牌或墓地存在满足特殊召唤条件的6星以下恶魔族·天使族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=c:IsCanRemoveCounter(tp,0x74,3,REASON_COST)
		-- 且自己的卡组存在满足条件的暗属性·10星怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b3=c:IsCanRemoveCounter(tp,0x74,5,REASON_COST)
		-- 且当前玩家场上存在可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手牌或墓地存在满足特殊召唤条件的10星怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	-- 供玩家选择要发动的子效果分支（1个、3个或5个指示物对应的效果）
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"手卡·墓地特殊召唤6星以下怪兽"
			{b2,aux.Stringid(id,2),3},  --"检索暗属性10星怪兽"
			{b3,aux.Stringid(id,3),5})  --"手卡·墓地特殊召10星怪兽"
	c:RemoveCounter(tp,0x74,op,REASON_COST)
	e:SetLabel(op)
end
-- 效果②（去除指示物选择发动对应效果）的发动判定与效果分类设置函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 或者在自己的卡组中存在可以加入手牌的暗属性·10星怪兽
		and (Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 或者当前玩家场上存在可用的怪兽区域空格
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手牌或墓地中存在至少1只可以特殊召唤的6星以下恶魔族·天使族怪兽
		and (Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 或者自己的手牌或墓地中存在至少1只可以特殊召唤的10星怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)))) end
	local op=e:GetLabel()
	if op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 如果选择了3个指示物的效果分支，则设置效果处理的连锁操作信息为从卡组检索卡片
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 如果选择了1个或5个指示物的效果分支，则设置效果处理的连锁操作信息为从手牌·墓地特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
-- 效果②（去除指示物选择发动对应效果）的效果处理主函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 如果当前玩家场上没有可用的怪兽区域空格，则无法特殊召唤并结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向发动效果的玩家提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家在自己手牌或墓地选择1只不受「王家长眠之谷」影响的6星以下恶魔族·天使族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==3 then
		-- 向发动效果的玩家提示选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家在卡组中选择1只暗属性·10星怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入玩家手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示选择并加入手牌的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==5 then
		-- 如果当前玩家场上没有可用的怪兽区域空格，则无法特殊召唤并结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向发动效果的玩家提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家在自己手牌或墓地选择1只不受「王家长眠之谷」影响的10星怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
