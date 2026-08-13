--Kozmo－エピローグ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己的「星际仙踪」怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
-- ②：把墓地的这张卡除外才能发动。这个回合，自己的「星际仙踪」怪兽的战斗让自己受到战斗伤害的场合只有1次，作为代替让自己基本分回复那个数值。
function c12385638.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①效果：只要这张卡在魔法与陷阱区域存在，自己的「星际仙踪」怪兽战斗破坏的怪兽不送去墓地回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c12385638.tdtg)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
	-- ②效果：把墓地的这张卡除外才能发动。这个回合，自己的「星际仙踪」怪兽的战斗让自己受到战斗伤害的场合只有1次，作为代替让自己基本分回复那个数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动代价：从墓地将这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(c12385638.operation)
	c:RegisterEffect(e3)
end
-- 筛选被战斗破坏的怪兽：判定其是否为「星际仙踪」怪兽（卡名属于0xd2字段），是则以卡组代替墓地作为战斗破坏的去向。
function c12385638.tdtg(e,c)
	return c:IsSetCard(0xd2)
end
-- ②效果处理时：为本回合生成一个影响我方玩家的战斗伤害反转效果（将满足条件的战斗伤害变为回复），持续到回合结束。
function c12385638.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ②效果：这个回合，自己的「星际仙踪」怪兽的战斗让自己受到战斗伤害的场合只有1次，作为代替让自己基本分回复那个数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c12385638.valcon)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害反转效果注册给玩家tp，作为以玩家为对象的环境效果开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害反转效果的条件判定：仅在战斗伤害、且我方「星际仙踪」怪兽参与了该战斗、且本回合尚未适用过的情况下，才把战斗伤害替换为基本分回复。
function c12385638.valcon(e,re,r,rp,rc)
	if bit.band(r,REASON_BATTLE)~=0 then
		local tp=e:GetHandlerPlayer()
		local bc=rc:GetBattleTarget()
		if bc and bc:IsSetCard(0xd2) and bc:IsControler(tp)
			-- 检查玩家tp是否已有标记12385638：为0表示本回合尚未使用过该效果，确保“只有1次”的限制。
			and Duel.GetFlagEffect(tp,12385638)==0 then
			-- 玩家tp注册本回合的标记12385638，在结束阶段重置，记录该效果已适用过一次，防止同回合内重复发动。
			Duel.RegisterFlagEffect(tp,12385638,RESET_PHASE+PHASE_END,0,1)
			return true
		end
	end
	return false
end
