--オルターガイスト・ヘクスティア
-- 效果：
-- 「幻变骚灵」怪兽2只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升这张卡所连接区的「幻变骚灵」怪兽的原本攻击力数值。
-- ②：魔法·陷阱卡的效果发动时，把这张卡所连接区1只「幻变骚灵」怪兽解放才能发动。那个发动无效并破坏。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「幻变骚灵」卡加入手卡。
function c1508649.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2张以上属于「幻变骚灵」的怪兽作为连接素材
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
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「幻变骚灵」卡加入手卡。
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
-- 过滤满足条件的「幻变骚灵」怪兽，必须是表侧表示且攻击力不为负数
function c1508649.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:GetBaseAttack()>=0
end
-- 计算连接区中满足条件的「幻变骚灵」怪兽的原本攻击力总和
function c1508649.atkval(e,c)
	local lg=c:GetLinkedGroup():Filter(c1508649.atkfilter,nil)
	return lg:GetSum(Card.GetBaseAttack)
end
-- 判断连锁是否为魔法或陷阱卡的发动且可以被无效
function c1508649.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断连锁是否为魔法或陷阱卡的发动且可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤满足条件的「幻变骚灵」怪兽，必须在连接区中且未被战斗破坏
function c1508649.cfilter(c,g)
	return c:IsSetCard(0x103)
		and g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查并选择1只满足条件的「幻变骚灵」怪兽进行解放作为代价
function c1508649.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1508649.cfilter,1,nil,lg) end
	-- 选择1只满足条件的「幻变骚灵」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c1508649.cfilter,1,1,nil,lg)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏
function c1508649.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行连锁无效和破坏操作
function c1508649.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁无效且效果对象存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏连锁对象
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断此卡是否从场上送去墓地
function c1508649.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「幻变骚灵」卡，必须可以送去手卡
function c1508649.thfilter(c)
	return c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- 设置检索操作信息
function c1508649.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「幻变骚灵」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1508649.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡送去手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并确认卡片
function c1508649.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1张满足条件的「幻变骚灵」卡
	local g=Duel.SelectMatchingCard(tp,c1508649.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
