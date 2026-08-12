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
-- 判断该效果是否可以发动
function c12235475.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡未在本次伤害计算中使用过此效果且参与了战斗
	return c:GetFlagEffect(12235475)==0 and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 设置发动此效果的费用
function c12235475.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可作为费用送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1张手牌送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(12235475,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 发动效果时执行的处理
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
