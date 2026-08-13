--星痕の機界騎士
-- 效果：
-- 「机界骑士」怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：和这张卡相同纵列没有其他卡存在的场合，这张卡可以直接攻击。
-- ②：额外怪兽区域的这张卡的所连接区没有怪兽存在的场合，这张卡不会被效果破坏，不会成为对方的效果的对象。
-- ③：把和这张卡相同纵列1张其他的自己的卡送去墓地才能发动。从卡组把1只「机界骑士」怪兽守备表示特殊召唤。
function c38502358.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只以上持有「机界骑士」字段（0x10c）的连接怪兽作为连接素材（对应召唤条件「机界骑士」怪兽2只以上）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x10c),2)
	-- ①：和这张卡相同纵列没有其他卡存在的场合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c38502358.dircon)
	c:RegisterEffect(e1)
	-- ②：额外怪兽区域的这张卡的所连接区没有怪兽存在的场合，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c38502358.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 为②后半段的“不会成为对方的效果的对象”设置判定规则，使这张卡不会成为对方的效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：把和这张卡相同纵列1张其他的自己的卡送去墓地才能发动。从卡组把1只「机界骑士」怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38502358,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,38502358)
	e4:SetCost(c38502358.spcost)
	e4:SetTarget(c38502358.sptg)
	e4:SetOperation(c38502358.spop)
	c:RegisterEffect(e4)
end
-- 直接攻击条件的判定：若这张卡所在纵列没有其他卡（同纵列卡数为0），则满足直接攻击条件，返回真。
function c38502358.dircon(e)
	return e:GetHandler():GetColumnGroupCount()==0
end
-- 抗性条件的判定：这张卡位于额外怪兽区域、是连接怪兽，且所连接区没有怪兽存在时，返回真，从而获得相应抗性。
function c38502358.indcon(e)
	local c=e:GetHandler()
	return c:GetSequence()>4 and c:IsType(TYPE_LINK) and c:GetLinkedGroupCount()==0
end
-- ③的代价过滤函数：候选卡需与这张卡处于同一纵列（属于cg）、可以作为代价送去墓地，且将其送墓后自己场上仍有空余怪兽区，确保后续特殊召唤能够进行。
function c38502358.spcfilter(c,g,tp)
	-- 判定条件依次为：候选卡包含在同一纵列的其他卡集合中；此卡可以作为代价送去墓地；此卡送墓后自己场上仍有可用的怪兽区域。
	return g:IsContains(c) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤对象过滤：从卡组中选出持有「机界骑士」字段（0x10c）、并且可以被当前效果以表侧守备表示特殊召唤的怪兽。
function c38502358.spfilter(c,e,tp)
	return c:IsSetCard(0x10c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③的代价处理：先取得这张卡所在纵列的其他卡集合cg；发动时检查是否存在可选的代价卡，然后让玩家选择1张符合条件的卡并作为代价送去墓地。
function c38502358.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	-- 发动时检查：确认自己场上是否存在1张与这张卡同一纵列、可作代价且送墓后有空余怪兽区的卡，以决定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c38502358.spcfilter,tp,LOCATION_ONFIELD,0,1,c,cg,tp) end
	-- 给玩家显示“请选择要送去墓地的卡”的选择提示，为接下来的选择卡操作设置提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足③代价条件的卡（同纵列、可作代价、送墓后有空位），排除这张卡自身，选择结果存入局部变量g。
	local g=Duel.SelectMatchingCard(tp,c38502358.spcfilter,tp,LOCATION_ONFIELD,0,1,1,c,cg,tp)
	-- 将选择的卡以代价（REASON_COST）的形式送去墓地，完成③的发动代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③的效果发动目标/合法性检查：确认卡组中存在可特殊召唤的「机界骑士」怪兽，并登记本次操作将进行卡组怪兽的特殊召唤。
function c38502358.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：确认卡组中是否存在1只符合条件（「机界骑士」字段且可表侧守备特殊召唤）的怪兽，作为效果处理的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c38502358.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果处理将把1只怪兽从卡组特殊召唤，用于给其他卡/效果提供时点检测信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：在空余怪兽区存在的情况下，从卡组选择1只「机界骑士」怪兽，以表侧守备表示特殊召唤到自己场上。
function c38502358.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则无法进行特殊召唤，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示，为接下来的选择卡操作设置提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「机界骑士」怪兽（可表侧守备特殊召唤），选择结果存入局部变量g。
	local g=Duel.SelectMatchingCard(tp,c38502358.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「机界骑士」怪兽以表侧守备表示特殊召唤到发动玩家自己场上，按正常特殊召唤规则处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
