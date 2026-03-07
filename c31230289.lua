--らくがきじゅう－すてご
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有恐龙族怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「涂鸦本」魔法·陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
function c31230289.initial_effect(c)
	-- ①：自己场上的怪兽不存在的场合或者只有恐龙族怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31230289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31230289)
	e1:SetCondition(c31230289.spcon)
	e1:SetTarget(c31230289.sptg)
	e1:SetOperation(c31230289.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「涂鸦本」魔法·陷阱卡加入手卡。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31230289,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31230290)
	e2:SetTarget(c31230289.thtg)
	e2:SetOperation(c31230289.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在非恐龙族或里侧表示的怪兽
function c31230289.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_DINOSAUR)
end
-- 效果条件函数，判断自己场上是否不存在怪兽或只有恐龙族怪兽
function c31230289.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的所有怪兽
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return not g:IsExists(c31230289.cfilter,1,nil)
end
-- 效果目标设置函数，判断是否满足特殊召唤条件
function c31230289.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将卡片特殊召唤到场上
function c31230289.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于筛选「涂鸦本」魔法·陷阱卡
function c31230289.thfilter(c)
	return c:IsSetCard(0x2185) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果目标设置函数，判断是否能检索「涂鸦本」魔法·陷阱卡
function c31230289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「涂鸦本」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31230289.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索「涂鸦本」魔法·陷阱卡的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组检索「涂鸦本」魔法·陷阱卡并丢弃手卡
function c31230289.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的「涂鸦本」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c31230289.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认展示选中的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 丢弃一张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
