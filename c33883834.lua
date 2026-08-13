--紫炎の寄子
-- 效果：
-- 自己场上存在的名字带有「六武众」的怪兽进行战斗的场合，那次伤害计算时把这张卡从手卡送去墓地发动。那只怪兽在这个回合不会被战斗破坏。
function c33883834.initial_effect(c)
	-- 自己场上存在的名字带有「六武众」的怪兽进行战斗的场合，那次伤害计算时把这张卡从手卡送去墓地发动。那只怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33883834,0))  --"不被战斗破坏"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c33883834.con)
	e1:SetCost(c33883834.cost)
	e1:SetOperation(c33883834.op)
	c:RegisterEffect(e1)
end
-- 判断发动条件：当前伤害计算时，进行战斗的攻击方或攻击对象中存在自己操控的「六武众」怪兽，且本回合尚未发动过此效果（flag为0）。
function c33883834.con(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	return d and ((a:IsControler(tp) and a:IsSetCard(0x103d)) or (d:IsControler(tp) and d:IsSetCard(0x103d)))
		-- 检查自己尚未发动过本效果，保证同一次伤害计算只能发动一次。
		and Duel.GetFlagEffect(tp,33883834)==0
end
-- 支付发动代价：确认手牌中的此卡能作为cost送入墓地；随后将其送入墓地，并注册一个伤害计算阶段结束即重置的发动标记，用于防止重复发动。
function c33883834.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手牌送入墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	-- 为发动者登记本效果的发动标记，该标记在伤害计算阶段结束时清除；配合condition中的检查，使同一伤害计算阶段内只能发动一次。
	Duel.RegisterFlagEffect(tp,33883834,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果处理：若攻击怪兽和攻击对象仍与本次战斗关联，则给自己操控的那只进行战斗的「六武众」怪兽附加“不会因战斗被破坏”的效果，直到回合结束。
function c33883834.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	-- 那只怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	if a:IsControler(tp) then
		a:RegisterEffect(e1)
	else
		d:RegisterEffect(e1)
	end
end
