--剛鬼ザ・ジャイアント・オーガ
-- 效果：
-- 「刚鬼」怪兽3只以上
-- ①：场上的这张卡不会被战斗破坏，不受持有这张卡的攻击力以下的攻击力的对方怪兽的所发动的效果影响。
-- ②：以场上的这张卡或者这张卡所连接区的怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效。
-- ③：1回合1次，这张卡的攻击力和原本攻击力不同的场合才能发动。这张卡的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
function c47946130.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要以3只以上「刚鬼」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),3)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：不受持有这张卡的攻击力以下的攻击力的对方怪兽的所发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c47946130.immval)
	c:RegisterEffect(e2)
	-- ②：以场上的这张卡或者这张卡所连接区的怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47946130,0))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c47946130.negcon)
	e3:SetTarget(c47946130.negtg)
	e3:SetOperation(c47946130.negop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，这张卡的攻击力和原本攻击力不同的场合才能发动。这张卡的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47946130,1))  --"攻击力上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c47946130.atkcon)
	e4:SetOperation(c47946130.atkop)
	c:RegisterEffect(e4)
end
-- 免疫效果的判定函数：只免疫对方怪兽发动的、已经发动的、攻击力不高于这张卡当前攻击力的效果。
function c47946130.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack() and te:IsActivated()
end
-- 过滤函数：判断传入的卡片是否存在于集合g中，用于确认连锁对象是否包含在‘本卡或本卡连接区’的集合内。
function c47946130.negfilter(c,g)
	return g:IsContains(c)
end
-- ②的发动条件：对方回合且本卡未被战斗破坏确定；对方发动的效果必须是取对象效果，且对象包含本卡或本卡连接区的怪兽，同时该连锁可以被无效。
function c47946130.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	lg:AddCard(c)
	-- 获取当前连锁（ev）的效果对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认连锁对象存在且包含于本卡或连接区的集合中，并且该连锁可以被无效。
	return tg and lg:IsExists(c47946130.negfilter,1,nil,tg) and Duel.IsChainNegatable(ev)
end
-- ②的发动目标设定：检查阶段直接允许发动，并将本次处理标记为无效对方发动的操作。
function c47946130.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁将无效对方发动的效果（eg），分类为CATEGORY_NEGATE。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②的发动处理：先检查本卡是否满足‘表侧表示、攻击力不低于500、仍与效果关联、当前正在处理的就是目标连锁’等条件，若满足则下降500攻击力并无效那个发动。
function c47946130.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:GetAttack()<500 or not c:IsRelateToEffect(e)
		-- 额外检查：当前连锁序号等于目标连锁序号+1（说明目标连锁尚未被其他效果插入处理），且本卡没有被战斗破坏确定。
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 这张卡的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	if not c:IsImmuneToEffect(e1) and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 将目标连锁ev的发动无效。
		Duel.NegateActivation(ev)
	end
end
-- ③的发动条件：这张卡的当前攻击力与原本攻击力不同，且满足伤害步骤内的时点限制。
function c47946130.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前攻击力不等于原本攻击力，并调用aux.dscon确保在伤害步骤内且尚未进行伤害计算时才能发动。
	return not c:IsAttack(c:GetBaseAttack()) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- ③的发动处理：确认本卡仍在场上且表侧表示后，赋予其攻击力上升1000直到回合结束的效果。
function c47946130.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
