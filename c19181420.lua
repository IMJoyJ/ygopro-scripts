--メメント・ツイン・ドラゴン
-- 效果：
-- 「莫忘」怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组把最多2只「莫忘」怪兽加入手卡（同名卡最多1张）。
-- ②：自己的「莫忘」怪兽战斗破坏的怪兽不去墓地而除外。
-- ③：融合召唤的这张卡被破坏的场合才能发动。从自己墓地把1只6星以下的「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册本卡的融合召唤条件以及①②③三个效果：融合素材为2只「莫忘」怪兽；①融合召唤成功时破坏1只「莫忘」怪兽并检索；②我方「莫忘」怪兽战斗破坏的怪兽改为除外；③融合召唤的这张卡被破坏时从墓地特招1只6星以下「莫忘」怪兽。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定需要2只满足「莫忘」字段条件的怪兽作为融合素材，true表示允许接触融合（素材在手卡·场上等区域直接返回额外卡组）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1a1),2,true)
	-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组把最多2只「莫忘」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏怪兽并检索「莫忘」怪兽"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的「莫忘」怪兽战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tdtg)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。从自己墓地把1只6星以下的「莫忘」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤「莫忘」怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡以融合召唤方式特殊召唤成功的场合才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选可作为破坏对象的卡：手卡或场上表侧表示、属于「莫忘」字段的怪兽。
function s.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a1) and c:IsFaceupEx()
end
-- 筛选可作为检索对象的卡：卡组中属于「莫忘」字段且能够加入手卡的怪兽。
function s.filter2(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动合法性检查：必须存在1只可破坏的「莫忘」怪兽，同时卡组存在至少1只可检索的「莫忘」怪兽，否则不能发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·场上是否存在至少1只「莫忘」怪兽可以作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 检查卡组中是否存在至少1只可以加入手卡的「莫忘」怪兽。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示本卡发动了当前效果，并显示效果文本，告知对方选择了这个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预定破坏1张自己手卡·场上的卡（具体对象处理时选择），用于连锁检测和效果交互。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置操作信息：预定将1张卡组中的卡加入手卡，用于连锁检测和效果交互。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：先选择1张手卡·场上表侧表示的「莫忘」怪兽破坏，破坏成功后再从卡组选择最多2张卡名不同的「莫忘」怪兽加入手卡，并向对方展示，然后洗切手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己的手卡·场上表侧表示的「莫忘」怪兽中选择1张作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 若确实选择了卡并且破坏处理成功（实际破坏了卡），则继续执行后续检索处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取卡组中所有满足条件的「莫忘」怪兽，作为检索选择的候选集合。
		local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
		-- 弹出选择提示，要求玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从候选组中选择1到2张满足条件的「莫忘」怪兽，且通过aux.dncheck保证选择的卡名互不相同（同名卡最多1张）。
		local tg=g2:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if tg then
			-- 将选中的「莫忘」怪兽加入其持有者的手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方玩家展示本次加入手卡的卡，以确认检索结果。
			Duel.ConfirmCards(1-tp,tg)
			-- 检索加入手卡后，洗切自己的手卡。
			Duel.ShuffleHand(tp)
		end
	end
end
-- ②效果的适用对象筛选：我方场上属于「莫忘」字段的怪兽在战斗破坏对方怪兽时，适用“不去墓地而除外”的重定向效果。
function s.tdtg(e,c)
	return c:IsSetCard(0x1a1)
end
-- ③效果的发动条件：这张卡被破坏时，其之前所在位置为场上，并且这张卡在场上时是以融合召唤方式召唤过的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ③效果的发动合法性检查：自己场上存在可用怪兽区，且墓地存在可特殊召唤的6星以下「莫忘」怪兽；并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域，以及墓地是否存在至少1只满足特殊召唤条件的「莫忘」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预定从墓地特殊召唤1只怪兽，用于连锁检测和效果交互。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 筛选符合条件的墓地怪兽：属于「莫忘」字段、等级6以下、并且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果处理：确认自己场上仍有可用怪兽区后，选择墓地1只符合条件的「莫忘」怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己场上是否有可用的怪兽区域，若没有则跳过特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只符合条件的「莫忘」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上，不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
