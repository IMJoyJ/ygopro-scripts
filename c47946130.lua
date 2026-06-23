--剛鬼ザ・ジャイアント・オーガ
-- 效果：
-- 「刚鬼」怪兽3只以上
-- ①：场上的这张卡不会被战斗破坏，不受持有这张卡的攻击力以下的攻击力的对方怪兽的所发动的效果影响。
-- ②：以场上的这张卡或者这张卡所连接区的怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效。
-- ③：1回合1次，这张卡的攻击力和原本攻击力不同的场合才能发动。这张卡的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
function c47946130.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少3个「刚鬼」连接怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),3)
	c:EnableReviveLimit()
	-- 场上的这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 不受持有这张卡的攻击力以下的攻击力的对方怪兽的所发动的效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c47946130.immval)
	c:RegisterEffect(e2)
	-- 以场上的这张卡或者这张卡所连接区的怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效
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
	-- 1回合1次，这张卡的攻击力和原本攻击力不同的场合才能发动。这张卡的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动
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
-- 效果免疫函数，判断是否免疫某个效果：该效果的发动者不是自己、是怪兽类型、发动者玩家不是自己玩家、发动者的攻击力不超过自己的攻击力、且该效果已被发动
function c47946130.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack() and te:IsActivated()
end
-- 过滤函数，用于判断卡片是否存在于目标组中
function c47946130.negfilter(c,g)
	return g:IsContains(c)
end
-- 无效效果发动的条件函数：对方发动效果、不是自己发动、自己未被战斗破坏、效果有对象、对象包含自己或连接怪兽、连锁可被无效
function c47946130.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local lg=e:GetHandler():GetLinkedGroup()
	lg:AddCard(c)
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回条件：对象存在、对象中包含自己或连接怪兽、连锁可被无效
	return tg and lg:IsExists(c47946130.negfilter,1,nil,tg) and Duel.IsChainNegatable(ev)
end
-- 设置连锁无效的处理目标，将发动效果设为无效
function c47946130.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记该效果会将对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果发动的操作函数：检查自身状态、满足条件则使攻击力下降500并无效连锁
function c47946130.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:GetAttack()<500 or not c:IsRelateToEffect(e)
		-- 判断当前连锁是否为当前处理的连锁，以及自己是否被战斗破坏
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 创建一个攻击力减少500的效果，并注册到场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	if not c:IsImmuneToEffect(e1) and not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 使当前连锁无效
		Duel.NegateActivation(ev)
	end
end
-- 攻击力上升效果的发动条件函数：攻击力与原本不同且在伤害步骤前
function c47946130.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回条件：攻击力和原本攻击力不同、满足伤害步骤前发动条件
	return not c:IsAttack(c:GetBaseAttack()) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 攻击力上升效果的操作函数：使自身攻击力增加1000，直到回合结束
function c47946130.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 创建一个攻击力增加1000的效果，并注册到场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
