--シールド・ウォリアー
-- 效果：
-- 战斗伤害计算时，把自己墓地存在的这张卡从游戏中除外才能发动。自己场上存在的怪兽不会被那次战斗破坏。
function c95360850.initial_effect(c)
	-- 战斗伤害计算时，把自己墓地存在的这张卡从游戏中除外才能发动。自己场上存在的怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95360850,0))  --"不被战斗破坏"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c95360850.atkcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c95360850.atkop)
	c:RegisterEffect(e1)
end
-- 发动条件：判断进行战斗的怪兽是否为自己场上的怪兽，并将其保存为标签对象。
function c95360850.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方怪兽，则将目标怪兽指向被攻击的怪兽（即自己场上的怪兽）。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsControler(tp)
end
-- 效果处理：使该次战斗中自己场上的怪兽不会被战斗破坏。
function c95360850.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 自己场上存在的怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
