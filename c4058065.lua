--ヴェルズ・サラマンドラ
-- 效果：
-- ①：从自己墓地把1只怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升300。这个效果1回合可以使用最多2次。
function c4058065.initial_effect(c)
	-- ①：从自己墓地把1只怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升300。这个效果1回合可以使用最多2次。
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
-- 过滤函数：筛选自己墓地里满足条件的怪兽，即该怪兽必须是怪兽卡且可以作为发动代价被除外。
function c4058065.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价函数整体：执行发动代价，检查自己墓地是否存在可除外的怪兽，若存在则提示玩家选择1只怪兽并表侧除外，作为发动本效果的代价。
function c4058065.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测（chk==0）：确认自己墓地是否存在至少1只满足代价条件的怪兽，用于判断效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4058065.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示消息，提示内容为“请选择要除外的卡”，并将该提示写入选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为对象，建立选择结果集g。
	local g=Duel.SelectMatchingCard(tp,c4058065.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择结果g中的怪兽以表侧表示除外，作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理函数整体：处理攻击力上升的后续效果，若这张卡仍然表侧表示且与发动效果存在关联，则为它注册一个使攻击力上升300的持续效果。
function c4058065.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到对方回合结束时上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
