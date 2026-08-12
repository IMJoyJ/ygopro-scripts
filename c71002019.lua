--六花精ボタン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤或者用植物族怪兽的效果特殊召唤成功的场合才能发动。从卡组把1张「六花」魔法·陷阱卡加入手卡。
function c71002019.initial_effect(c)
	-- ①：把自己场上1只植物族怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71002019,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71002019)
	e1:SetCost(c71002019.spcost)
	e1:SetTarget(c71002019.sptg)
	e1:SetOperation(c71002019.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤或者用植物族怪兽的效果特殊召唤成功的场合才能发动。从卡组把1张「六花」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71002019,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,71002020)
	e2:SetTarget(c71002019.thtg)
	e2:SetOperation(c71002019.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c71002019.thcon)
	c:RegisterEffect(e3)
end
-- 过滤条件：可解放的植物族怪兽（或受特定卡片效果影响的对方怪兽），且解放后能腾出足够的怪兽区域
function c71002019.rfilter(c,tp)
	-- 检查该卡解放后是否能让自身特殊召唤到怪兽区域，且如果是对方场上的卡必须是表侧表示
	return Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- 效果①的发动代价（Cost）处理函数
function c71002019.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查场上是否存在至少1只满足过滤条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c71002019.rfilter,1,nil,tp) end
	-- 向玩家发送提示信息：请选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足过滤条件的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c71002019.rfilter,1,1,nil,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果①的发动准备（Target）处理函数
function c71002019.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）函数
function c71002019.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中的「六花」魔法·陷阱卡，且能加入手卡
function c71002019.thfilter(c)
	return c:IsSetCard(0x141) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动准备（Target）处理函数
function c71002019.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71002019.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）函数
function c71002019.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c71002019.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②（特殊召唤成功时）的发动条件：检查自身是否是由植物族怪兽的效果特殊召唤成功
function c71002019.thcon(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_PLANT~=0
end
