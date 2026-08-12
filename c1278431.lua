--古代の機械素体
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。把1只「古代的机械巨人」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从手卡把「古代的机械巨人」「古代的机械巨人-究极重击」合计最多3只无视召唤条件特殊召唤。
function c1278431.initial_effect(c)
	-- 记录此卡效果文本中记载着「古代的机械巨人」这张卡名
	aux.AddCodeList(c,83104731)
	-- ①：丢弃1张手卡才能发动。把1只「古代的机械巨人」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1278431,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,1278431)
	e1:SetCost(c1278431.thcost)
	e1:SetTarget(c1278431.thtg)
	e1:SetOperation(c1278431.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c1278431.aclimit)
	e2:SetCondition(c1278431.actcon)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从手卡把「古代的机械巨人」「古代的机械巨人-究极重击」合计最多3只无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1278431,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c1278431.spcon)
	e3:SetTarget(c1278431.sptg)
	e3:SetOperation(c1278431.spop)
	c:RegisterEffect(e3)
end
-- 检查玩家手牌是否存在可丢弃的卡牌，若存在则丢弃1张手牌作为发动代价
function c1278431.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义检索过滤器，用于筛选卡组中是否含有「古代的机械巨人」或记载该卡名的魔法/陷阱卡
function c1278431.thfilter(c)
	-- 筛选条件：卡牌为「古代的机械巨人」或为魔法/陷阱卡且记载「古代的机械巨人」卡名
	return (c:IsCode(83104731) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,83104731))) and c:IsAbleToHand()
end
-- 设置效果处理时的检索目标，确定将要从卡组检索的卡牌数量和位置
function c1278431.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在满足检索条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c1278431.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的检索操作，选择并把符合条件的卡加入手牌
function c1278431.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1278431.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制对方不能发动魔法/陷阱卡的效果函数
function c1278431.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为攻击状态的此卡触发效果
function c1278431.actcon(e)
	-- 判断当前攻击的怪兽是否为本卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断此卡是否因对方效果离场且处于表侧表示状态
function c1278431.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 定义特殊召唤过滤器，用于筛选手牌中可特殊召唤的「古代的机械巨人」或「古代的机械巨人-究极重击」
function c1278431.spfilter(c,e,tp)
	return c:IsCode(83104731,95735217) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标和条件，检查手牌中是否存在满足条件的卡
function c1278431.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在满足特殊召唤条件的卡
		and Duel.IsExistingMatchingCard(c1278431.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果发动时的特殊召唤操作，选择并特殊召唤满足条件的怪兽
function c1278431.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算玩家最多可特殊召唤的怪兽数量，最多为3只
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	if ft<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c1278431.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
