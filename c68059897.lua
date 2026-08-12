--M∀LICE＜Q＞RED RANSOM
-- 效果：
-- 包含「码丽丝」怪兽的怪兽2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「码丽丝」魔法卡加入手卡。
-- ②：只要这张卡所连接区有怪兽存在，对方场上的效果怪兽的原本攻击力和原本守备力交换。
-- ③：这张卡被除外的场合，支付900基本分才能发动。这张卡特殊召唤。那之后，可以从卡组把1只电子界族怪兽除外。
local s,id,o=GetID()
-- 初始化效果注册：设置连接召唤手续、①效果（特殊召唤成功时检索魔法）、②效果（所连接区有怪兽时交换对方效果怪兽原本攻守）、③效果（被除外时支付生命值特召并可选除外卡组电子界怪兽）。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只以上怪兽作为素材，且必须包含满足s.lcheck过滤条件的怪兽（即「码丽丝」怪兽）。
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「码丽丝」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡所连接区有怪兽存在，对方场上的效果怪兽的原本攻击力和原本守备力交换。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atfilter)
	e2:SetCondition(s.atcon)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，支付900基本分才能发动。这张卡特殊召唤。那之后，可以从卡组把1只电子界族怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接素材检查：检查用于连接召唤的怪兽组中是否包含至少1只「码丽丝」怪兽（字段0x1bf）。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1bf)
end
-- 过滤函数：检索卡组中属于「码丽丝」系列（字段0x1bf）且可以加入手牌的魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①效果的发动准备（Target）：检查卡组中是否存在可检索的「码丽丝」魔法卡，并设置将卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「码丽丝」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：预计将1张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理（Operation）：从卡组选择1张「码丽丝」魔法卡加入手牌，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「码丽丝」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的适用条件：检查这张卡的所连接区是否存在怪兽。
function s.atcon(e)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and lg:FilterCount(Card.IsType,nil,TYPE_MONSTER)>0
end
-- ②效果的影响对象过滤：仅适用于效果怪兽。
function s.atfilter(e,c)
	return c:IsType(TYPE_EFFECT)
end
-- ③效果的发动代价（Cost）：检查并支付900点基本分。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付900点基本分。
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 扣除玩家900点基本分作为发动代价。
	Duel.PayLPCost(tp,900)
end
-- ③效果的发动准备（Target）：检查怪兽区域是否有空位，以及自身是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：预计将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：检索卡组中可以被除外的电子界族怪兽。
function s.rmfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ③效果的效果处理（Operation）：将自身特殊召唤，之后可以从卡组选择1只电子界族怪兽除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在可以被除外的电子界族怪兽。
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择发动后续的“从卡组把1只怪兽除外”的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把怪兽除外？"
		-- 中断当前效果处理，使后续的除外处理与特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从卡组中选择1张满足过滤条件的电子界族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽因效果表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
