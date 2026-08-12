--ジェム・マーチャント
-- 效果：
-- 自己场上表侧表示存在的地属性的通常怪兽进行战斗的伤害步骤时可以把这张卡从手卡送去墓地，那只怪兽的攻击力·守备力直到这个回合的结束阶段时上升1000。
function c53408006.initial_effect(c)
	-- 诱发即时效果，可以在伤害步骤时发动，将此卡从手牌送去墓地以提升怪兽攻守
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(53408006,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c53408006.condition)
	e1:SetCost(c53408006.cost)
	e1:SetOperation(c53408006.operation)
	c:RegisterEffect(e1)
end
-- 筛选地属性通常怪兽的过滤函数
function c53408006.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_NORMAL)
end
-- 判断是否处于伤害步骤且未计算战斗伤害，同时确认己方参与战斗的怪兽是否满足条件
function c53408006.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local phase=Duel.GetCurrentPhase()
	-- 若当前阶段不是伤害步骤或已计算战斗伤害，则效果不成立
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取防守怪兽
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and c53408006.filter(a) and a:IsRelateToBattle())
		or (d and d:IsControler(tp) and d:IsFaceup() and c53408006.filter(d) and d:IsRelateToBattle())
end
-- 支付代价，将此卡送去墓地
function c53408006.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手牌送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动效果，根据战斗情况提升怪兽攻守
function c53408006.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 若当前回合玩家不是自己，则取防守怪兽为作用对象
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 使目标怪兽攻击力上升1000直到回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	a:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	a:RegisterEffect(e2)
end
