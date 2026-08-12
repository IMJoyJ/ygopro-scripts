--サイバー・ドラゴン・コア
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡召唤的场合发动。从卡组把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
-- ③：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。从卡组把1只「电子龙」怪兽特殊召唤。
function c23893227.initial_effect(c)
	-- ②：这张卡召唤的场合发动。从卡组把1张「电子」魔法·陷阱卡或「电子科技」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23893227,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,23893227)
	e1:SetTarget(c23893227.target)
	e1:SetOperation(c23893227.operation)
	c:RegisterEffect(e1)
	-- ③：只有对方场上才有怪兽存在的场合，把墓地的这张卡除外才能发动。从卡组把1只「电子龙」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23893227,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23893227)
	e2:SetCondition(c23893227.spcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23893227.sptg)
	e2:SetOperation(c23893227.spop)
	c:RegisterEffect(e2)
	-- 使此卡在场上或墓地时视为「电子龙」
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
end
-- 过滤函数，用于检索满足条件的「电子」或「电子科技」魔法·陷阱卡
function c23893227.filter(c)
	return c:IsSetCard(0x93,0x94) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组区域为1张卡
function c23893227.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要检索的卡组区域为1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择满足条件的卡加入手牌并确认
function c23893227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c23893227.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断对方场上是否有怪兽，己方场上是否无怪兽
function c23893227.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否有怪兽，己方场上是否无怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数，用于检索满足条件的「电子龙」怪兽
function c23893227.spfilter(c,e,tp)
	return c:IsSetCard(0x1093) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时要特殊召唤的卡组区域为1只怪兽
function c23893227.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c23893227.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡组区域为1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果，选择满足条件的怪兽特殊召唤
function c23893227.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c23893227.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
