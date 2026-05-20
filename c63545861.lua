--セイクリッドの流星
-- 效果：
-- 这张卡发动的回合，和名字带有「星圣」的怪兽进行战斗没被战斗破坏的对方怪兽在伤害步骤结束时回到持有者卡组。
function c63545861.initial_effect(c)
	-- 这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63545861.target)
	e1:SetOperation(c63545861.regop)
	c:RegisterEffect(e1)
end
-- 卡片发动的Target函数，用于确认是否为卡片发动
function c63545861.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 卡片发动的Operation函数，用于注册一个在回合结束前有效的、在伤害步骤结束时触发的全局效果
function c63545861.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 和名字带有「星圣」的怪兽进行战斗没被战斗破坏的对方怪兽在伤害步骤结束时回到持有者卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c63545861.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给发动卡片的玩家，使其在全局环境生效
	Duel.RegisterEffect(e1,tp)
end
-- 伤害步骤结束时的效果处理，检查战斗双方，将与「星圣」怪兽战斗且仍留在场上的对方怪兽送回持有者卡组
function c63545861.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.CreateGroup()
	if a:IsSetCard(0x53) and d and d:IsControler(1-tp) and d:IsRelateToBattle() then g:AddCard(d) end
	if d and d:IsSetCard(0x53) and a:IsControler(1-tp) and a:IsRelateToBattle() then g:AddCard(a) end
	-- 将符合条件的怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
