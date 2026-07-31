--運命の契約
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次自己场上的卡被战斗·效果破坏，给这张卡放置1个皇之键指示物（最多1个）。
-- ②：对方从额外卡组把怪兽特殊召唤的场合，把这张卡1个皇之键指示物取除才能发动。从手卡·卡组以及自己场上的表侧表示的卡之中把1张「命运之扉」送去墓地，从额外卡组把1只光属性「霍普」超量怪兽当作超量召唤作特殊召唤，把这张卡在那只怪兽下面重叠作为超量素材。
function c32245230.initial_effect(c)
	c:EnableCounterPermit(0x5e,LOCATION_SZONE)
	c:SetCounterLimit(0x5e,1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 创建效果，设置类型为激活，代码为自由连锁，注册该效果。此效果用于处理战斗/效果破坏时增加指示物的逻辑。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(c32245230.ctop)
	c:RegisterEffect(e1)
	-- 创建效果，描述为“特殊召唤「霍普」超量怪兽”，类别为送去墓地+特殊召唤，类型为场地触发型，设置延迟标志，代码为特殊召唤成功，范围为魔陷区，限制次数为1次（卡名限制），条件为c32245230.spcon，费用为c32245230.spcost，目标为c32245230.sptg，操作为c32245230.spop，注册该效果。此效果是卡牌主要效果的实现。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32245230,0))  --"特殊召唤「霍普」超量怪兽"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,32245230)
	e2:SetCondition(c32245230.spcon)
	e2:SetCost(c32245230.spcost)
	e2:SetTarget(c32245230.sptg)
	e2:SetOperation(c32245230.spop)
	c:RegisterEffect(e2)
end
c32245230.mentioned_counter={
	[0x5e]=true,
}
-- 定义过滤函数 c32245230.cfilter，用于检查卡片是否属于之前的控制者、破坏原因是否为战斗或效果、以及之前的位置是否在场上。
function c32245230.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 执行效果 c32245230.ctop。如果存在满足 c32245230.cfilter 条件的卡牌，则给这张卡添加一个 0x5e (皇之键) 指示物。
function c32245230.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c32245230.cfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x5e,1)
	end
end
-- 定义过滤函数 c32245230.cfilter2，用于检查卡片是否在额外卡组被特殊召唤，且特殊召唤者是对方玩家。
function c32245230.cfilter2(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
-- 执行效果 c32245230.spcon。如果存在满足 c32245230.cfilter2 条件的卡牌，则返回 true，否则返回 false。此函数作为特殊召唤效果的条件。
function c32245230.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32245230.cfilter2,1,nil,tp)
end
-- 执行效果 c32245230.spcost。如果检查值为 0，则返回这张卡是否可以移除一个 0x5e 指示物（用于费用支付）。如果检查值不为 0，则移除一个 0x5e 指示物。
function c32245230.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x5e,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x5e,1,REASON_COST)
end
-- 定义过滤函数 c32245230.tgfilter，用于选择要送去墓地的「命运之扉」。
function c32245230.tgfilter(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
		and c:IsCode(27062594) and c:IsAbleToGrave()
end
-- 定义过滤函数 c32245230.spfilter，用于筛选符合条件的“霍普”超量怪兽。
function c32245230.spfilter(c,e,tp)
	return c:IsSetCard(0x7f) and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 检查目标怪兽是否可以特殊召唤，并且额外卡组有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 执行效果 c32245230.sptg。如果检查值为 0，则返回是否存在满足 c32245230.tgfilter 条件的卡牌、aux.MustMaterialCheck 是否为真、以及这张卡是否可以作为超量素材和额外卡组中是否有符合条件的怪兽。
function c32245230.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手牌/卡组/场上是否存在「命运之扉」。
	if chk==0 then return Duel.IsExistingMatchingCard(c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil)
		-- 检查目标怪兽是否必须成为超量素材，并且当前卡片是否可以进行叠放。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and e:GetHandler():IsCanOverlay()
		-- 判断额外卡组中是否存在符合条件的“霍普”超量怪兽。
		and Duel.IsExistingMatchingCard(c32245230.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：类别为送去墓地，数量为 1，目标玩家为发动者，位置为手牌/卡组/场上。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	-- 设置操作信息：类别为特殊召唤，数量为 1，目标玩家为发动者，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行效果 c32245230.spop。获取这张卡的处理对象，提示选择要送去墓地的卡牌，选择满足 c32245230.tgfilter 条件的卡牌并将其送去墓地。如果成功，则提示选择要特殊召唤的卡牌，选择满足 c32245230.spfilter 条件的卡牌并将其特殊召唤为超量怪兽，然后将这张卡叠放在该怪兽下面。
function c32245230.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示信息，要求选择送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌、卡组和场上选择一张符合 c32245230.tgfilter 条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c32245230.tgfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
	-- 如果选择了卡片并且成功将其送去墓地，则继续执行后续操作。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		-- 检查目标怪兽是否必须成为超量素材。如果不是，则直接返回。
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组中选择一张符合 c32245230.spfilter 条件的卡片。
		local sg=Duel.SelectMatchingCard(tp,c32245230.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(nil)
			-- 如果成功特殊召唤了选定的怪兽，则执行后续操作。
			if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				sc:CompleteProcedure()
				if c:IsRelateToEffect(e) and c:IsCanOverlay() then
					-- 将当前卡片叠放在特殊召唤的超量怪兽下面。
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
	end
end
