--獣王無塵
-- 效果：
-- 这个卡名的①的效果在同一连锁上只能发动1次。
-- ①：1回合1次，自己怪兽和与自身相同纵列的对方怪兽进行战斗的伤害步骤开始时才能发动。和那只自己怪兽相同纵列的卡全部回到持有者手卡。
function c50675040.initial_effect(c)
	-- ①：1回合1次，自己怪兽和与自身相同纵列的对方怪兽进行战斗的伤害步骤开始时才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	e0:SetTarget(c50675040.target)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己怪兽和与自身相同纵列的对方怪兽进行战斗的伤害步骤开始时才能发动。和那只自己怪兽相同纵列的卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50675040,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c50675040.thcon)
	e1:SetTarget(c50675040.thtg)
	e1:SetOperation(c50675040.thop)
	c:RegisterEffect(e1)
end
-- 作为卡片的发动条件判定：非伤害阶段可直接发动；伤害阶段则必须满足①效果的发动条件（同纵列战斗的伤害步骤开始时），且若满足则将本次发动按①效果处理，设置回手相关操作，否则不设置操作。
function c50675040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前阶段是否不在伤害阶段，即是否处于通常可发动魔陷的阶段。
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	-- 检查当前是否处于伤害步骤开始时（EVENT_BATTLE_START），且满足①效果的发动条件与目标要求，用于判断能否作为①效果发动。
	local b2=Duel.CheckEvent(EVENT_BATTLE_START) and c50675040.thcon(e,tp,eg,ep,ev,re,r,rp) and c50675040.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	if b2 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(c50675040.thop)
		c50675040.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- ①效果的发动条件：取得正在战斗的攻击怪兽与被攻击怪兽，若攻击者不是己方怪兽则交换两者，确保己方怪兽与对方怪兽同纵列且均与本次战斗关联；将该己方怪兽存入效果标签供后续处理使用。
function c50675040.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得本次战斗的被攻击怪兽，若没有攻击对象则返回 nil。
	local b=Duel.GetAttackTarget()
	if not b then return false end
	if not a:IsControler(tp) then a,b=b,a end
	local lg=a:GetColumnGroup()
	if not lg:IsContains(b) then return false end
	e:SetLabelObject(a)
	return a:IsControler(tp) and a:IsRelateToBattle() and b:IsControler(1-tp) and b:IsRelateToBattle()
end
-- ①效果的发动目标判定与发动时处理：检查对象怪兽可回手且本回合未使用过同名卡效果；合法后登记本次发动的同名卡限制标志，并选取该怪兽及其同纵列所有可回手的卡作为返回手牌的对象，设置操作信息。
function c50675040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=e:GetLabelObject()
	local c=e:GetHandler()
	-- 发动合法性检查：需要存在该我方怪兽、能回手，且我方没有本连锁的同名①效果使用记录，且这张卡自身没有本回合①效果使用记录。
	if chk==0 then return a and a:IsAbleToHand() and Duel.GetFlagEffect(tp,50675040)==0 and c:GetFlagEffect(50675041)==0 end
	-- 给玩家登记一个连锁结束时重置的标识，用于限制这个卡名的①效果在同一连锁上只能发动1次。
	Duel.RegisterFlagEffect(tp,50675040,RESET_CHAIN,0,1)
	c:RegisterFlagEffect(50675041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local g=a:GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	g:AddCard(a)
	-- 将返回手牌对象的卡组 g 及其数量写入连锁操作信息，用于向系统和其他卡宣告本次效果要处理的是这些卡回手。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果处理：确认保存的我方怪兽仍与本次战斗相关且控制权仍为我方，则将其和他当前同纵列的卡全部加入同一组，准备返回手牌。
function c50675040.thop(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetLabelObject()
	if a and a:IsRelateToBattle() and a:IsControler(tp) then
		local g=a:GetColumnGroup()
		g:AddCard(a)
		if g:GetCount()>0 then
			-- 将该组卡全部返回持有者手卡，返回原因是效果处理。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
