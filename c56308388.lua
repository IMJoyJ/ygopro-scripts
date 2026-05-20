--クロノダイバー・リューズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1个超量素材取除才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「时间潜行者·表冠操作员」以外的1张「时间潜行者」卡加入手卡。
function c56308388.initial_effect(c)
	-- ①：把自己场上1个超量素材取除才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56308388,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56308388)
	e1:SetCost(c56308388.spcost)
	e1:SetTarget(c56308388.sptg)
	e1:SetOperation(c56308388.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「时间潜行者·表冠操作员」以外的1张「时间潜行者」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56308388,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,56308389)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c56308388.thtg)
	e2:SetOperation(c56308388.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的代价（Cost）函数：检查并取除自己场上的超量素材
function c56308388.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在可以作为代价取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 作为发动代价，取除自己场上的1个超量素材
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 效果①的发动准备（Target）函数：检查自身能否特殊召唤并设置操作信息
function c56308388.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段检查自己场上是否有空余的怪兽区域，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置操作信息，表示此效果的处理为将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理（Operation）函数：将这张卡特殊召唤
function c56308388.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选卡组中「时间潜行者·表冠操作员」以外的「时间潜行者」卡片
function c56308388.thfilter(c)
	return c:IsSetCard(0x126) and c:IsAbleToHand() and not c:IsCode(56308388)
end
-- 效果②的发动准备（Target）函数：检查卡组中是否存在可检索的卡片并设置操作信息
function c56308388.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c56308388.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数：从卡组检索卡片并给对方确认
function c56308388.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c56308388.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
