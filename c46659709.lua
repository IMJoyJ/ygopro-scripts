--銀河戦士
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从手卡把1只其他的光属性怪兽送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：这张卡特殊召唤时才能发动。从卡组把1只「银河」怪兽加入手卡。
function c46659709.initial_effect(c)
	-- ①：从手卡把1只其他的光属性怪兽送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46659709,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c46659709.spcost)
	e1:SetTarget(c46659709.sptg)
	e1:SetOperation(c46659709.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤时才能发动。从卡组把1只「银河」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46659709,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,46659709)
	e2:SetTarget(c46659709.target)
	e2:SetOperation(c46659709.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否存在光属性且能作为代价送去墓地的怪兽。
function c46659709.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToGraveAsCost()
end
-- 效果处理时检查是否满足发动条件并执行丢弃手牌的操作。
function c46659709.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的自己的手牌区是否存在至少1张满足cfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46659709.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从玩家tp的手牌中选择并以REASON_COST原因丢弃满足cfilter条件的1张卡。
	Duel.DiscardHand(tp,c46659709.cfilter,1,1,REASON_COST,e:GetHandler())
end
-- 设置特殊召唤效果的目标，检查是否有足够的场上空间以及该卡是否可以被特殊召唤。
function c46659709.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp的场上主怪兽区是否有可用空间。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，执行将自身特殊召唤到场上的动作。
function c46659709.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以守备表示特殊召唤到玩家tp的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤函数，用于判断卡组中是否存在「银河」怪兽且能加入手牌。
function c46659709.filter(c)
	return c:IsSetCard(0x7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标，检查卡组中是否存在满足filter条件的卡。
function c46659709.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的自己的卡组区是否存在至少1张满足filter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46659709.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行从卡组检索并加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择一张「银河」怪兽加入手牌并确认对方可见。
function c46659709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp发送提示消息“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家tp的卡组中选择满足filter条件的1张卡作为目标。
	local g=Duel.SelectMatchingCard(tp,c46659709.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以REASON_EFFECT原因送入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡牌内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
