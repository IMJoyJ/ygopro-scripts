--魔轟神アシェンヴェイル
-- 效果：
-- ①：这张卡进行战斗的那次伤害计算时1次，把1张手卡送去墓地才能发动。这张卡的攻击力只在那次伤害计算时上升600。
function c12235475.initial_effect(c)
	-- ①：这张卡进行战斗的那次伤害计算时1次，把1张手卡送去墓地才能发动。这张卡的攻击力只在那次伤害计算时上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12235475,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c12235475.con)
	e1:SetCost(c12235475.cost)
	e1:SetOperation(c12235475.op)
	c:RegisterEffect(e1)
end
-- 伤害计算时的发动条件判断：该卡进行战斗且本回合尚未使用过此效果（通过标识计数判断）。
function c12235475.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真值的条件：这张卡没有使用过本效果的标识，并且这张卡是攻击怪兽或攻击目标。只有满足这些条件，效果才能在伤害计算时发动。
	return c:GetFlagEffect(12235475)==0 and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 发动代价整体处理：从手牌选择1张卡作为代价送去墓地，并给这张卡注册一个在伤害计算阶段结束时重置的标识，以防止本次伤害计算时重复发动。
function c12235475.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检测：如果只是检查（chk==0），则确认自己手牌中是否存在可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，要求玩家选择1张要送去墓地的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手牌中选择1张卡（将作为代价送去墓地）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手牌送去墓地，作为发动效果的代价，原因是代价。
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(12235475,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果处理：给自己这张卡注册一个在伤害计算阶段结束时重置的攻击力上升600的永续效果（只在该次伤害计算时适用）。
function c12235475.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力只在那次伤害计算时上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(600)
	c:RegisterEffect(e1)
end
