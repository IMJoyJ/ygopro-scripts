--月輪鏡
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次怪兽被战斗·效果破坏，每有1只给这张卡放置1个月轮指示物。
-- ②：可以把这张卡的月轮指示物的以下数量取除，那个效果发动。
-- ●1个：从自己的手卡·墓地把1只6星以下的恶魔族·天使族怪兽特殊召唤。
-- ●3个：从卡组把1只暗属性·10星怪兽加入手卡。
-- ●5个：从自己的手卡·墓地把1只10星怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：允许放置月轮指示物（0x74）；注册永续魔法发动所需的自由时点空效果；注册怪兽被战斗·效果破坏时放置指示物的永续触发效果（e2）；注册②的起动效果（e3，1回合1次，含特殊召唤·检索·加入手卡分类）
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
	-- ②：可以把这张卡的月轮指示物的以下数量取除，那个效果发动。这个卡名的②的效果1回合只能使用1次。
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
-- 过滤被破坏的卡：先前在怪兽区域的卡，或先前不在场上但本身是怪兽卡的卡，且是被战斗或效果破坏的
function s.ctfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or
		not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER))
		and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
-- 触发条件：本次被破坏的卡中存在至少1只满足过滤条件的怪兽
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil)
end
-- 统计本次被破坏的满足条件的怪兽数量，每有1只给这张卡放置1个月轮指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.ctfilter,nil)
	e:GetHandler():AddCounter(0x74,ct)
end
-- 特殊召唤对象过滤：6星以下的恶魔族·天使族怪兽且可以被特殊召唤
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_FAIRY+RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索对象过滤：暗属性·10星怪兽且可以加入手卡
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevel(10) and c:IsAbleToHand()
end
-- 特殊召唤对象过滤：10星怪兽且可以被特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价处理：分别检查能否取除1/3/5个月轮指示物且对应效果可执行；让发动玩家从可执行的选项中选择一项，取除相应数量的月轮指示物作为代价，并把选择的数量记入标签
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=c:IsCanRemoveCounter(tp,0x74,1,REASON_COST)
		-- 且自己的主要怪兽区有空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手卡·墓地存在6星以下的恶魔族·天使族可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=c:IsCanRemoveCounter(tp,0x74,3,REASON_COST)
		-- 且卡组存在暗属性·10星怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b3=c:IsCanRemoveCounter(tp,0x74,5,REASON_COST)
		-- 且自己的主要怪兽区有空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手卡·墓地存在可特殊召唤的10星怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	-- 让发动玩家从可执行的选项中选择要发动的效果
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"手卡·墓地特殊召唤6星以下怪兽"
			{b2,aux.Stringid(id,2),3},  --"检索暗属性10星怪兽"
			{b3,aux.Stringid(id,3),5})  --"手卡·墓地特殊召10星怪兽"
	c:RemoveCounter(tp,0x74,op,REASON_COST)
	e:SetLabel(op)
end
-- 目标检查：卡组存在暗属性·10星怪兽，或主要怪兽区有空格且手卡·墓地存在可特殊召唤的6星以下恶魔族·天使族怪兽或10星怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 卡组存在暗属性·10星怪兽
		and (Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 或自己的主要怪兽区有空格
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡·墓地存在6星以下的恶魔族·天使族可特殊召唤的怪兽
		and (Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 或手卡·墓地存在可特殊召唤的10星怪兽
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)))) end
	local op=e:GetLabel()
	if op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置操作信息：将从卡组把1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置操作信息：将从手卡·墓地把1只怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
-- 效果处理：根据选择的数量执行对应效果——1个：把手卡·墓地1只6星以下的恶魔族·天使族怪兽特殊召唤；3个：把卡组1只暗属性·10星怪兽加入手卡并给对方确认；5个：把手卡·墓地1只10星怪兽特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 若自己的主要怪兽区没有空格则中止处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只6星以下的恶魔族·天使族可特殊召唤的怪兽（不受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==3 then
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只暗属性·10星怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡以效果原因加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 把加入手卡的卡给对方玩家确认
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==5 then
		-- 若自己的主要怪兽区没有空格则中止处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只可特殊召唤的10星怪兽（不受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
