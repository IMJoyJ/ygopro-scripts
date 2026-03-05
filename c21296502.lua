--トゥーン・ブラック・マジシャン
-- 效果：
-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
-- ③：1回合1次，可以从手卡丢弃1张「卡通」卡，从以下效果选择1个发动。
-- ●从卡组把「卡通黑魔术师」以外的1只卡通怪兽无视召唤条件特殊召唤。
-- ●从卡组把1张「卡通」魔法·陷阱卡加入手卡。
function c21296502.initial_effect(c)
	-- 记录该卡牌具有「卡通世界」的卡名信息
	aux.AddCodeList(c,15259703)
	-- ①：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c21296502.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c21296502.dircon)
	c:RegisterEffect(e4)
	-- ③：1回合1次，可以从手卡丢弃1张「卡通」卡，从以下效果选择1个发动。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(21296502,0))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c21296502.cost)
	e5:SetTarget(c21296502.sptg)
	e5:SetOperation(c21296502.spop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetDescription(aux.Stringid(21296502,1))  --"卡组检索"
	e6:SetTarget(c21296502.thtg)
	e6:SetOperation(c21296502.thop)
	c:RegisterEffect(e6)
end
-- 在召唤·反转召唤·特殊召唤成功时，使该卡在本回合不能攻击
function c21296502.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 使该卡在本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 用于判断场上是否存在「卡通世界」
function c21296502.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 用于判断对方场上是否存在卡通怪兽
function c21296502.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断是否满足直接攻击的条件
function c21296502.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断己方场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c21296502.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在卡通怪兽
		and not Duel.IsExistingMatchingCard(c21296502.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 用于判断手卡中是否存在可丢弃的「卡通」卡
function c21296502.costfilter(c)
	return c:IsSetCard(0x62) and c:IsDiscardable()
end
-- 支付效果代价，丢弃1张「卡通」卡
function c21296502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的「卡通」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21296502.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示对方玩家该卡发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从手卡丢弃1张「卡通」卡作为效果代价
	Duel.DiscardHand(tp,c21296502.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 用于判断卡组中是否存在可加入手牌的「卡通」魔法·陷阱卡
function c21296502.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x62) and c:IsAbleToHand()
end
-- 设置检索效果的处理信息
function c21296502.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的「卡通」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21296502.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择1张「卡通」魔法·陷阱卡加入手牌
function c21296502.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「卡通」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c21296502.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 用于判断卡组中是否存在可特殊召唤的「卡通」怪兽
function c21296502.spfilter(c,e,tp)
	return c:IsType(TYPE_TOON) and not c:IsCode(21296502) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的处理信息
function c21296502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可特殊召唤的「卡通」怪兽
		and Duel.IsExistingMatchingCard(c21296502.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果，从卡组特殊召唤1只「卡通」怪兽
function c21296502.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「卡通」怪兽
	local g=Duel.SelectMatchingCard(tp,c21296502.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
