--捕食植物スパイダー・オーキッド
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段，以这张卡以外的魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的回合的结束阶段，从手卡丢弃1只植物族怪兽才能发动。从卡组把1只4星以下的植物族怪兽加入手卡。
function c30537973.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的自己主要阶段，以这张卡以外的魔法与陷阱区域1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c30537973.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功的回合的结束阶段，从手卡丢弃1只植物族怪兽才能发动。从卡组把1只4星以下的植物族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30537973,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,30537973)
	e2:SetCondition(c30537973.descon)
	e2:SetTarget(c30537973.destg)
	e2:SetOperation(c30537973.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的灵摆效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30537973,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,30537974)
	e3:SetCost(c30537973.thcost)
	e3:SetTarget(c30537973.thtg)
	e3:SetOperation(c30537973.thop)
	c:RegisterEffect(e3)
	if not c30537973.global_check then
		c30537973.global_check=true
		-- 这个卡名的怪兽效果1回合只能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(30537973)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置效果处理函数为aux.sumreg，用于处理“这张卡召唤的回合”的效果
		ge1:SetOperation(aux.sumreg)
		-- 将效果ge1注册给玩家0（全局环境）
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(30537973)
		-- 将效果ge2注册给玩家0（全局环境）
		Duel.RegisterEffect(ge2,0)
	end
end
-- 注册flag标记，用于记录该卡是否已发动过灵摆效果
function c30537973.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(30537973,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断该卡是否已发动过灵摆效果
function c30537973.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(30537973)~=0
end
-- 过滤函数，用于筛选表侧表示且位于魔法与陷阱区域的卡
function c30537973.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 设置破坏效果的目标选择函数
function c30537973.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and chkc~=c and c30537973.desfilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c30537973.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c30537973.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,c)
	-- 设置操作信息，表示将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作
function c30537973.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选植物族且可丢弃的卡
function c30537973.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsDiscardable()
end
-- 设置怪兽效果的发动条件，检查是否已发动过灵摆效果并确认手牌中存在植物族可丢弃的卡
function c30537973.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(30537973)~=0
		-- 确认手牌中存在植物族可丢弃的卡
		and Duel.IsExistingMatchingCard(c30537973.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中丢弃1张植物族卡
	Duel.DiscardHand(tp,c30537973.costfilter,1,1,REASON_DISCARD+REASON_COST)
	e:GetHandler():ResetFlagEffect(30537973)
end
-- 过滤函数，用于筛选4星以下且为植物族的卡
function c30537973.thfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsAbleToHand()
end
-- 设置检索效果的目标选择函数
function c30537973.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30537973.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果
function c30537973.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c30537973.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
