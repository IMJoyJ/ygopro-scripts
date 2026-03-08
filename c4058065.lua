--ヴェルズ・サラマンドラ
-- 效果：
-- ①：从自己墓地把1只怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升300。这个效果1回合可以使用最多2次。
function c4058065.initial_effect(c)
	-- 效果原文内容：①：从自己墓地把1只怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升300。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4058065,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c4058065.cost)
	e1:SetOperation(c4058065.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查玩家的墓地是否存在满足条件的怪兽（可除外作为代价）
function c4058065.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果的发动费用处理函数，检查是否有满足条件的怪兽可除外，并执行除外操作
function c4058065.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己墓地是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4058065.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡从墓地除外
	local g=Duel.SelectMatchingCard(tp,c4058065.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从游戏中除外（作为发动代价）
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的处理函数，用于提升自身攻击力
function c4058065.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：这张卡的攻击力直到对方回合结束时上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
