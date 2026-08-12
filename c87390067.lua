--BF－蒼天のジェット
-- 效果：
-- 战斗伤害计算时，把这张卡从手卡送去墓地发动。自己场上存在的名字带有「黑羽」的怪兽不会被那次战斗破坏。
function c87390067.initial_effect(c)
	-- 战斗伤害计算时，把这张卡从手卡送去墓地发动。自己场上存在的名字带有「黑羽」的怪兽不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(87390067,0))  --"不被战斗破坏"
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c87390067.condition)
	e2:SetCost(c87390067.cost)
	e2:SetOperation(c87390067.operation)
	c:RegisterEffect(e2)
end
-- 判断是否在伤害计算时，且进行战斗的怪兽中存在自己场上的「黑羽」怪兽
function c87390067.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	return (a:IsControler(tp) and a:IsSetCard(0x33))
		or (d:IsControler(tp) and d:IsSetCard(0x33))
end
-- 检查并执行发动代价：将此卡从手牌送去墓地
function c87390067.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：使进行战斗的自己场上的「黑羽」怪兽在本次伤害计算中获得战斗无伤耐性
function c87390067.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 如果当前回合玩家不是自己，则将目标怪兽设定为被攻击怪兽（即自己场上的怪兽）
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	-- 自己场上存在的名字带有「黑羽」的怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(1)
	a:RegisterEffect(e1)
end
