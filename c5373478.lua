--サイバー・ドラゴン・ツヴァイ
-- 效果：
-- ①：这张卡的卡名只要在墓地存在当作「电子龙」使用。
-- ②：1回合1次，把手卡1张魔法卡给对方观看才能发动。这张卡的卡名直到结束阶段当作「电子龙」使用。
-- ③：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
function c5373478.initial_effect(c)
	-- 效果原文：③：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c5373478.atkcon)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- 效果原文：②：1回合1次，把手卡1张魔法卡给对方观看才能发动。这张卡的卡名直到结束阶段当作「电子龙」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5373478,0))  --"卡名当成「电子龙」"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c5373478.cost)
	e2:SetOperation(c5373478.cdop)
	c:RegisterEffect(e2)
	-- 使该卡在墓地时视为「电子龙」（卡号70095154）
	aux.EnableChangeCode(c,70095154,LOCATION_GRAVE)
end
-- 判断是否处于伤害步骤且为攻击怪兽
function c5373478.atkcon(e)
	-- 获取当前阶段
	local phase=Duel.GetCurrentPhase()
	return (phase==PHASE_DAMAGE or phase==PHASE_DAMAGE_CAL)
		-- 判断是否为攻击怪兽且对方有攻击目标
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
-- 过滤手卡中未公开的魔法卡
function c5373478.costfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 选择并确认一张手卡中的魔法卡给对方观看，然后洗切手牌
function c5373478.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在未公开的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c5373478.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手卡中的魔法卡
	local g=Duel.SelectMatchingCard(tp,c5373478.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的魔法卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 将该卡的卡名变更成「电子龙」（卡号70095154）直到结束阶段
function c5373478.cdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 将该卡的卡名变更成「电子龙」（卡号70095154）直到结束阶段
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(70095154)
	c:RegisterEffect(e1)
end
