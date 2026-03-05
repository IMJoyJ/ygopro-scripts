--ストーム・サモナー
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，可以让这张卡以外的念动力族怪兽战斗破坏的对方怪兽不送去墓地，在对方卡组最上面放置。这张卡被卡的效果破坏时，这张卡的控制者受到这张卡的攻击力数值的伤害。
function c15935204.initial_effect(c)
	-- 效果原文内容：只要这张卡在自己场上表侧表示存在，可以让这张卡以外的念动力族怪兽战斗破坏的对方怪兽不送去墓地，在对方卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(c15935204.reptg)
	-- 规则层面操作：设置效果值为假，表示该效果不执行替换动作，仅用于触发条件判断。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡被卡的效果破坏时，这张卡的控制者受到这张卡的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15935204,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c15935204.dmcon)
	e2:SetTarget(c15935204.dmtg)
	e2:SetOperation(c15935204.dmop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：筛选满足条件的被战斗破坏且非衍生物、对方控制、来自念动力族怪兽、未被送去卡组的怪兽。
function c15935204.repfilter(c,e,tp)
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsType(TYPE_TOKEN)
		and c:IsControler(1-tp) and c:IsReason(REASON_BATTLE) and c:GetReasonCard():IsRace(RACE_PSYCHO) and c:GetReasonCard()~=e:GetHandler()
		and c:GetLeaveFieldDest()==0 and c:GetDestination()~=LOCATION_DECK
end
-- 规则层面操作：判断是否选择使用「风暴召唤师」的效果，若选择则为符合条件的怪兽设置离开场上的重定向效果。
function c15935204.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return r&REASON_BATTLE~=0 and eg:IsExists(c15935204.repfilter,1,nil,e,tp) end
	-- 规则层面操作：提示玩家是否使用「风暴召唤师」的效果。
	if Duel.SelectYesNo(tp,aux.Stringid(15935204,1)) then  --"是否要使用「风暴召唤师」的效果？"
		local tc=eg:Filter(c15935204.repfilter,nil,e,tp):GetFirst()
		-- 效果原文内容：只要这张卡在自己场上表侧表示存在，可以让这张卡以外的念动力族怪兽战斗破坏的对方怪兽不送去墓地，在对方卡组最上面放置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetCondition(c15935204.recon)
		e1:SetValue(LOCATION_DECK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		return true
	else return false end
end
-- 规则层面操作：判断怪兽是否因战斗离开场上的状态且去向为墓地。
function c15935204.recon(e)
	local c=e:GetHandler()
	return c:GetDestination()==LOCATION_GRAVE and c:IsReason(REASON_BATTLE)
end
-- 规则层面操作：判断该卡不是因战斗被破坏。
function c15935204.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面操作：设置伤害效果的目标玩家和伤害值。
function c15935204.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 规则层面操作：设置伤害效果的目标玩家为该卡之前的控制者。
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 规则层面操作：设置伤害效果的伤害值为该卡的攻击力。
	Duel.SetTargetParam(c:GetAttack())
	-- 规则层面操作：设置连锁操作信息为伤害效果，目标为该卡的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),c:GetAttack())
end
-- 规则层面操作：执行伤害效果，对目标玩家造成指定伤害。
function c15935204.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁中目标玩家和目标参数（即伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：以效果原因对指定玩家造成指定伤害值。
	Duel.Damage(p,d,REASON_EFFECT)
end
