--未来王の予言
-- 效果：
-- 自己场上存在的魔法师族怪兽的攻击破坏对方怪兽的场合，那个伤害步骤结束时才能发动。那只怪兽只有1次可以继续攻击。这张卡发动的回合，自己不能召唤·反转召唤·特殊召唤。
function c57274196.initial_effect(c)
	-- 自己场上存在的魔法师族怪兽的攻击破坏对方怪兽的场合，那个伤害步骤结束时才能发动。那只怪兽只有1次可以继续攻击。这张卡发动的回合，自己不能召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c57274196.condition)
	e1:SetCost(c57274196.cost)
	e1:SetOperation(c57274196.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上的魔法师族怪兽战斗破坏对方怪兽，且该怪兽可以进行连续攻击
function c57274196.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsRace(RACE_SPELLCASTER) and tc:IsChainAttackable() and tc:IsStatus(STATUS_OPPO_BATTLE)
end
-- 检查发动代价：本回合自己是否未进行过召唤、反转召唤和特殊召唤
function c57274196.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查本回合是否未进行过反转召唤和特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能召唤·反转召唤·特殊召唤。那只怪兽只有1次可以继续攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	-- 给玩家注册本回合不能特殊召唤的约束效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 给玩家注册本回合不能通常召唤的约束效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 给玩家注册本回合不能反转召唤的约束效果
	Duel.RegisterEffect(e3,tp)
end
-- 执行效果：使该怪兽可以再进行1次攻击
function c57274196.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使进行战斗的怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
