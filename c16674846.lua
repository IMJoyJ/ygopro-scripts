--スピリット・フォース
-- 效果：
-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0。那之后，可以把自己墓地存在的1只守备力1500以下的战士族调整加入手卡。
function c16674846.initial_effect(c)
	-- 对方回合的战斗伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0。那之后，可以把自己墓地存在的1只守备力1500以下的战士族调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c16674846.condition)
	e1:SetOperation(c16674846.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅在对方回合且本次战斗将对己方造成战斗伤害时，该卡才能发动。
function c16674846.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合（Duel.GetTurnPlayer()~=tp）且本次战斗伤害计算时己方受到的战斗伤害大于0，两者同时满足时条件成立。
	return Duel.GetTurnPlayer()~=tp and Duel.GetBattleDamage(tp)>0
end
-- 定义检索过滤条件：从己方墓地选择守备力1500以下、调整、战士族且可以被加入手卡的怪兽。
function c16674846.filter(c)
	return c:IsDefenseBelow(1500) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_WARRIOR)
		and c:IsAbleToHand()
end
-- 定义效果处理函数：先使那次战斗对自己的战斗伤害变成0，然后若墓地存在符合条件的怪兽，由玩家选择是否将其中1只加入手卡。
function c16674846.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 那次战斗发生的对自己的战斗伤害变成0。那之后，可以把自己墓地存在的1只守备力1500以下的战士族调整加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册给当前玩家tp，使该效果在本伤害步骤结束前生效，从而把这次对自己的战斗伤害变成0。
	Duel.RegisterEffect(e1,tp)
	-- 获取己方墓地中满足过滤条件（守备力1500以下、调整、战士族、可加入手卡）且不受“王家长眠之谷”影响的卡的集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16674846.filter),tp,LOCATION_GRAVE,0,nil)
	-- 若墓地存在符合条件的卡，且当前玩家选择“是”，则执行加入手卡的处理。
	if g:GetCount()~=0 and Duel.SelectYesNo(tp,aux.Stringid(16674846,0)) then  --"是否要把墓地的1只守备力1500以下的战士族调整加入手卡？"
		-- 向当前玩家发送选择卡片的提示消息，提示内容为“请选择要加入手牌的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡以效果原因送去持有者的手卡（即加入手卡）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
