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
	-- 和那只自己怪兽相同纵列的卡全部回到持有者手卡。
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
-- 检查当前是否可以发动效果，包括当前阶段不是伤害步骤或满足触发条件
function c50675040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前阶段是否不是伤害步骤
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
	-- 判断是否在伤害步骤开始时触发且满足条件
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
-- 判断攻击怪兽与防守怪兽是否在同一纵列并设置标签对象
function c50675040.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取当前防守的怪兽
	local b=Duel.GetAttackTarget()
	if not b then return false end
	if not a:IsControler(tp) then a,b=b,a end
	local lg=a:GetColumnGroup()
	if not lg:IsContains(b) then return false end
	e:SetLabelObject(a)
	return a:IsControler(tp) and a:IsRelateToBattle() and b:IsControler(1-tp) and b:IsRelateToBattle()
end
-- 检查目标怪兽是否可以送回手牌并注册连锁限制标识
function c50675040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=e:GetLabelObject()
	local c=e:GetHandler()
	-- 判断目标怪兽是否可送回手牌且未在本连锁发动过
	if chk==0 then return a and a:IsAbleToHand() and Duel.GetFlagEffect(tp,50675040)==0 and c:GetFlagEffect(50675041)==0 end
	-- 为玩家注册一个在连锁结束时重置的标识效果，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,50675040,RESET_CHAIN,0,1)
	c:RegisterFlagEffect(50675041,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local g=a:GetColumnGroup():Filter(Card.IsAbleToHand,nil)
	g:AddCard(a)
	-- 设置操作信息，指定将卡送回手牌的效果分类和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 执行效果处理，将目标怪兽及其同纵列的卡送回手牌
function c50675040.thop(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetLabelObject()
	if a and a:IsRelateToBattle() and a:IsControler(tp) then
		local g=a:GetColumnGroup()
		g:AddCard(a)
		if g:GetCount()>0 then
			-- 将符合条件的卡送回持有者手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
