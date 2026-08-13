--アロマセラフィ－ジャスミン
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己基本分比对方多的场合，这张卡以及这张卡所连接区的植物族怪兽不会被战斗破坏。
-- ②：把这张卡所连接区1只自己怪兽解放才能发动。从卡组把1只植物族怪兽守备表示特殊召唤。
-- ③：1回合1次，自己基本分回复的场合发动。从卡组把1只植物族怪兽加入手卡。
function c21200905.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要植物族连接怪兽2只作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	-- ①：自己基本分比对方多的场合，这张卡以及这张卡所连接区的植物族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c21200905.indcon)
	e1:SetTarget(c21200905.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：把这张卡所连接区1只自己怪兽解放才能发动。从卡组把1只植物族怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21200905,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21200905)
	e2:SetCost(c21200905.spcost)
	e2:SetTarget(c21200905.sptg)
	e2:SetOperation(c21200905.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己基本分回复的场合发动。从卡组把1只植物族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21200905,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_RECOVER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c21200905.thcon)
	e3:SetTarget(c21200905.thtg)
	e3:SetOperation(c21200905.thop)
	c:RegisterEffect(e3)
end
-- ①效果的适用条件：自己基本分高于对方。
function c21200905.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断自己基本分是否比对方多。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 保护对象为这张卡自身，或这张卡所连接区的植物族怪兽。
function c21200905.indtg(e,c)
	return e:GetHandler()==c or (c:IsRace(RACE_PLANT) and e:GetHandler():GetLinkedGroup():IsContains(c))
end
-- 过滤函数：判断目标卡是否属于这张卡所连接区的卡片组。
function c21200905.cfilter(c,g)
	return g:IsContains(c)
end
-- ②效果的代价：将自己场上位于这张卡所连接区的1只怪兽解放。
function c21200905.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 发动时检查是否存在可解放的位于连接区的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c21200905.cfilter,1,nil,lg) end
	-- 选择1只位于连接区的自己怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c21200905.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放（作为代价）。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤的卡需为植物族，且可以以表侧守备表示特殊召唤。
function c21200905.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动时检查：自己的主要怪兽区有空位，且卡组中存在可特殊召唤的植物族怪兽。
function c21200905.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用区域（此处用>-1放宽判断）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否有1只满足特殊召唤条件的植物族怪兽。
		and Duel.IsExistingMatchingCard(c21200905.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息为从卡组特殊召唤1只植物族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只植物族怪兽，以表侧守备表示特殊召唤。
function c21200905.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若没有可用主要怪兽区域则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择卡片的提示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,c21200905.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ③效果的触发条件：自己回复了基本分。
function c21200905.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 检索的卡需为植物族，且可以被加入手卡。
function c21200905.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- ③效果发动时必定可发动，设置从卡组检索植物族怪兽的操作信息。
function c21200905.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果处理的信息为从卡组将1只植物族怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1只植物族怪兽加入手卡，并让对方确认。
function c21200905.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片的提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,c21200905.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
