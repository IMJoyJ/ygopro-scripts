--紋章獣アンフィスバエナ
-- 效果：
-- 自己的主要阶段时，从手卡把这张卡以外的1只名字带有「纹章兽」的怪兽丢弃才能发动。这张卡从手卡特殊召唤。此外，1回合1次，从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。这张卡的攻击力直到结束阶段时上升800。
function c87255382.initial_effect(c)
	-- 自己的主要阶段时，从手卡把这张卡以外的1只名字带有「纹章兽」的怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87255382,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c87255382.cost)
	e1:SetTarget(c87255382.sptg)
	e1:SetOperation(c87255382.spop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。这张卡的攻击力直到结束阶段时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87255382,1))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c87255382.cost)
	e2:SetOperation(c87255382.atkop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中名字带有「纹章兽」且可以丢弃的怪兽
function c87255382.cfilter(c)
	return c:IsSetCard(0x76) and c:IsDiscardable()
end
-- 丢弃手牌中1只自身以外的名字带有「纹章兽」的怪兽作为发动的代价
function c87255382.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身以外的1只名字带有「纹章兽」且可以丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87255382.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手牌中除自身以外的1只名字带有「纹章兽」的怪兽丢弃
	Duel.DiscardHand(tp,c87255382.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤效果的发动准备，检查怪兽区域是否有空位以及自身是否可以特殊召唤
function c87255382.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理，将自身从手牌特殊召唤
function c87255382.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击力上升效果的实际处理，使自身攻击力直到结束阶段时上升800
function c87255382.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到结束阶段时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
