--ヴォルカニック・トルーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「火山骑兵」以外的1张「火山」卡加入手卡。
-- ②：丢弃1张手卡才能发动。在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
function c22411609.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「火山骑兵」以外的1张「火山」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22411609,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,22411609)
	e1:SetTarget(c22411609.thtg)
	e1:SetOperation(c22411609.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：丢弃1张手卡才能发动。在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22411609,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,22411610)
	e3:SetCost(c22411609.tkcost)
	e3:SetTarget(c22411609.tktg)
	e3:SetOperation(c22411609.tkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的「火山」卡（不包括火山骑兵本身）
function c22411609.thfilter(c)
	return c:IsSetCard(0x32) and not c:IsCode(22411609) and c:IsAbleToHand()
end
-- 效果处理时的判断条件，检查是否满足检索条件
function c22411609.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的「火山」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22411609.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并检索满足条件的卡
function c22411609.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c22411609.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 丢弃手卡作为发动代价
function c22411609.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置特殊召唤衍生物的条件
function c22411609.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22411610,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) end
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物并设置其效果
function c22411609.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
	-- 检查是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,22411610,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) then return end
	-- 创建「炸弹衍生物」
	local token=Duel.CreateToken(tp,22411610)
	-- 特殊召唤衍生物
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 为衍生物设置被破坏时造成伤害的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c22411609.damop)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 衍生物被破坏时造成伤害的效果处理函数
function c22411609.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 对衍生物的控制者造成500伤害
		Duel.Damage(c:GetPreviousControler(),500,REASON_EFFECT)
	end
	e:Reset()
end
