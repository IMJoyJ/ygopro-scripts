--I：Pマスカレーナ
-- 效果：
-- 连接怪兽以外的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行连接召唤。
-- ②：这张卡为连接素材的连接怪兽不会被对方的效果破坏。
function c65741786.initial_effect(c)
	-- 设置连接召唤的手续：连接怪兽以外的怪兽2只
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK)),2,2)
	c:EnableReviveLimit()
	-- ①：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65741786,0))  --"连接召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,65741786)
	e1:SetCondition(c65741786.lkcon)
	e1:SetTarget(c65741786.lktg)
	e1:SetOperation(c65741786.lkop)
	c:RegisterEffect(e1)
	-- ②：这张卡为连接素材的连接怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c65741786.indcon)
	e2:SetOperation(c65741786.indop)
	c:RegisterEffect(e2)
end
-- 判断是否在对方回合的主要阶段，作为效果①的发动条件
function c65741786.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
		-- 检查当前阶段是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果①的发动准备，检查是否存在可连接召唤的怪兽并设置操作信息
function c65741786.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在可以用包含这张卡的场上怪兽作为素材进行连接召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,e:GetHandler()) end
	-- 设置特殊召唤的操作信息，用于连锁处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理，执行连接召唤
function c65741786.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可以用包含这张卡的场上怪兽作为素材进行连接召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,nil,c)
	if g:GetCount()>0 then
		-- 在客户端显示“请选择要特殊召唤的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 使用包含这张卡的场上怪兽作为素材，将选中的怪兽进行连接召唤
		Duel.LinkSummon(tp,sg:GetFirst(),nil,c)
	end
end
-- 检查这张卡是否是因为进行连接召唤而送去墓地（作为连接素材）
function c65741786.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 为以此卡为素材连接召唤的怪兽添加“不会被对方的效果破坏”的效果
function c65741786.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为连接素材的连接怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65741786,1))  --"「I：P百变莱娜」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(c65741786.indval)
	e1:SetOwnerPlayer(ep)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 抗性效果的值函数，限制破坏效果的来源必须是对方玩家
function c65741786.indval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
