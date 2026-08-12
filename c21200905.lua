--アロマセラフィ－ジャスミン
-- 效果：
-- 植物族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己基本分比对方多的场合，这张卡以及这张卡所连接区的植物族怪兽不会被战斗破坏。
-- ②：把这张卡所连接区1只自己怪兽解放才能发动。从卡组把1只植物族怪兽守备表示特殊召唤。
-- ③：1回合1次，自己基本分回复的场合发动。从卡组把1只植物族怪兽加入手卡。
function c21200905.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只植物族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,2)
	-- 自己基本分比对方多的场合，这张卡以及这张卡所连接区的植物族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c21200905.indcon)
	e1:SetTarget(c21200905.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 把这张卡所连接区1只自己怪兽解放才能发动。从卡组把1只植物族怪兽守备表示特殊召唤。
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
	-- 1回合1次，自己基本分回复的场合发动。从卡组把1只植物族怪兽加入手卡。
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
-- 判断是否满足效果发动条件：当前玩家的LP大于对方玩家的LP
function c21200905.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 当前玩家的LP大于对方玩家的LP
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- 设置效果目标：当前卡片或连接区的植物族怪兽
function c21200905.indtg(e,c)
	return e:GetHandler()==c or (c:IsRace(RACE_PLANT) and e:GetHandler():GetLinkedGroup():IsContains(c))
end
-- 过滤函数：判断卡片是否在指定组中
function c21200905.cfilter(c,g)
	return g:IsContains(c)
end
-- 效果发动时的费用支付处理：选择并解放连接区的1只怪兽
function c21200905.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c21200905.cfilter,1,nil,lg) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c21200905.cfilter,1,1,nil,lg)
	-- 执行怪兽解放操作
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：筛选可特殊召唤的植物族怪兽
function c21200905.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的条件：场上存在可特殊召唤的植物族怪兽
function c21200905.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足条件的植物族怪兽
		and Duel.IsExistingMatchingCard(c21200905.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只植物族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作：从卡组选择并特殊召唤1只植物族怪兽
function c21200905.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c21200905.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判断是否满足效果发动条件：当前玩家回复LP
function c21200905.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤函数：筛选可加入手牌的植物族怪兽
function c21200905.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 设置效果发动时的条件：无特殊限制
function c21200905.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：准备将1只植物族怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果操作：从卡组选择并加入手牌
function c21200905.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c21200905.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
