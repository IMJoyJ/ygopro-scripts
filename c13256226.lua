--E・HERO スピリット・オブ・ネオス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。这个效果特殊召唤的这张卡不会被战斗破坏。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张有「元素英雄」怪兽的卡名记述的魔法·陷阱卡或者「融合」加入手卡。
-- ③：自己主要阶段才能发动。这张卡回到持有者卡组，从卡组把1只「元素英雄」通常怪兽特殊召唤。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。这个效果特殊召唤的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1张有「元素英雄」怪兽的卡名记述的魔法·陷阱卡或者「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。这张卡回到持有者卡组，从卡组把1只「元素英雄」通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id+o*2)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 攻击宣言时的条件判断
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 设置特殊召唤的处理条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并设置不被战斗破坏效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤步骤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 设置不被战斗破坏效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 定义检索卡牌的过滤条件
function s.thfilter(c)
	-- 过滤条件：可加入手牌且为元素英雄系列魔法陷阱或融合
	return c:IsAbleToHand() and (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsSetNameMonsterListed(c,0x3008) or c:IsCode(24094653))
end
-- 设置检索效果的处理条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选择的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义特殊召唤目标的过滤条件
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置第三效果的处理条件
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断此卡是否能送入卡组且场上存在召唤空间
	if chk==0 then return c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 判断卡组中是否存在满足条件的元素英雄通常怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置送入卡组的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行第三效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能送入卡组且已送入卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) then
		-- 判断场上是否有召唤空间
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 执行特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
