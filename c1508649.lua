--オルターガイスト・ヘクスティア
-- 效果：
-- 「幻变骚灵」怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的「幻变骚灵」怪兽的原本攻击力数值。
-- ②：魔法·陷阱卡的效果发动时，把这张卡所连接区1只「幻变骚灵」怪兽解放才能发动。那个发动无效并破坏。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「幻变骚灵」卡加入手卡。
function c1508649.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：连接素材为2只「幻变骚灵」怪兽（即从额外卡组以2只「幻变骚灵」怪兽作为素材进行连接召唤）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x103),2,2)
	-- ①：这张卡的攻击力上升这张卡所连接区的「幻变骚灵」怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1508649.atkval)
	c:RegisterEffect(e1)
	-- ②：魔法·陷阱卡的效果发动时，把这张卡所连接区1只「幻变骚灵」怪兽解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1508649,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1508649.discon)
	e2:SetCost(c1508649.discost)
	e2:SetTarget(c1508649.distg)
	e2:SetOperation(c1508649.disop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「幻变骚灵」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1508649,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,1508649)
	e3:SetCondition(c1508649.thcon)
	e3:SetTarget(c1508649.thtg)
	e3:SetOperation(c1508649.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定怪兽是否为表侧表示且属于「幻变骚灵」，并且原本攻击力不为负（通常成立），用于选出连接区中能提供攻击力加成的怪兽。
function c1508649.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:GetBaseAttack()>=0
end
-- 计算攻击力上升值：取得这张卡连接区中满足条件的「幻变骚灵」怪兽，将它们的原本攻击力总和作为上升数值。
function c1508649.atkval(e,c)
	local lg=c:GetLinkedGroup():Filter(c1508649.atkfilter,nil)
	return lg:GetSum(Card.GetBaseAttack)
end
-- 效果发动条件：若这张卡处于战斗破坏确定状态则不能发动；且需要对方发动的效果是魔法·陷阱卡的效果，并且该连锁可以被无效。
function c1508649.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断正在发动的效果是否为魔法·陷阱卡效果，且该效果的发动能否被无效化。
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：用于选择解放对象的“连接区「幻变骚灵」怪兽”，要求该怪兽属于「幻变骚灵」、位于这张卡的连接区，且不处于战斗破坏确定状态。
function c1508649.cfilter(c,g)
	return c:IsSetCard(0x103)
		and g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②的发动代价：从这张卡连接区的「幻变骚灵」怪兽中解放1只。先检查是否存在符合条件的可解放怪兽，再选择并执行解放。
function c1508649.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价检查：确认场上是否存在至少1只满足条件的可解放的「幻变骚灵」怪兽（作为解放代价）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1508649.cfilter,1,nil,lg) end
	-- 选择代价怪兽：让玩家从满足条件的连接区「幻变骚灵」怪兽中选择1只作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c1508649.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 设定②的效果目标与操作信息：指定要无效的对象为正在发动的效果（eg）；若该效果的发卡怪兽可被破坏且仍与效果关联，则同时设定其为破坏对象。
function c1508649.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁将无效的对象为正在发动的魔法·陷阱卡效果（eg），供系统检测和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：如果发动效果的卡能够被破坏且仍与效果关联，则将其设定为破坏对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②的效果处理：先无效对方发动的效果，若成功且该卡仍与效果关联，则将其破坏。
function c1508649.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效发动，并确认发动效果的卡仍与效果有关联（防止无效后离场导致无法破坏）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的卡破坏，对应“并破坏”的效果处理。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ③的发动条件：这张卡被送去墓地时，其原来所在位置为场上（即从场上送去墓地）。
function c1508649.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：卡组中存在的「幻变骚灵」卡且能够加入手卡。
function c1508649.thfilter(c)
	return c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- 设定③的目标与操作信息：检查卡组是否存在符合条件的「幻变骚灵」卡，并设置从卡组检索加入手卡的操作信息。
function c1508649.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中是否存在至少1张符合条件的「幻变骚灵」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1508649.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果会将卡组中的1张卡加入手卡（用于系统检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：玩家从卡组选择1张「幻变骚灵」卡加入手卡，并展示给对方确认。
function c1508649.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的卡组中选择1张符合条件的「幻变骚灵」卡。
	local g=Duel.SelectMatchingCard(tp,c1508649.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去持有者的手卡（加入手牌）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
