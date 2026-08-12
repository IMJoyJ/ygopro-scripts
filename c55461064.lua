--D-HERO ダガーガイ
-- 效果：
-- 对方的战斗阶段时，从手卡把这张卡丢弃才能发动。自己场上的全部名字带有「命运英雄」的怪兽的攻击力直到结束阶段时上升800。
function c55461064.initial_effect(c)
	-- 对方的战斗阶段时，从手卡把这张卡丢弃才能发动。自己场上的全部名字带有「命运英雄」的怪兽的攻击力直到结束阶段时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55461064,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c55461064.atkcon)
	e1:SetCost(c55461064.atkcost)
	e1:SetTarget(c55461064.atktg)
	e1:SetOperation(c55461064.atkop)
	c:RegisterEffect(e1)
end
-- 判定发动条件是否满足对方的战斗阶段（非伤害计算后）
function c55461064.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前回合玩家为对方、当前阶段为战斗阶段，且非伤害计算后
	return Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 判定并执行把这张卡从手卡丢弃的发动代价
function c55461064.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤自己场上表侧表示的「命运英雄」怪兽
function c55461064.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 判定效果发动的可行性，即自己场上是否存在符合条件的怪兽
function c55461064.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在至少1只表侧表示的「命运英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55461064.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 执行效果，使自己场上全部「命运英雄」怪兽的攻击力直到结束阶段上升800
function c55461064.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上全部表侧表示的「命运英雄」怪兽
	local g=Duel.GetMatchingGroup(c55461064.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到结束阶段时上升800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetOwnerPlayer(tp)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
