--決別
-- 效果：
-- ①：对方战斗阶段从手卡把1张魔法卡送去墓地才能发动。那次战斗阶段结束。场上的表侧表示怪兽直到回合结束时效果无效化。
function c9852718.initial_effect(c)
	-- ①：对方战斗阶段从手卡把1张魔法卡送去墓地才能发动。那次战斗阶段结束。场上的表侧表示怪兽直到回合结束时效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c9852718.condition)
	e1:SetCost(c9852718.cost)
	e1:SetOperation(c9852718.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查当前是否为对方回合的战斗阶段
function c9852718.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为对方回合，且当前阶段处于战斗阶段开始到战斗阶段结束之间
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤条件：手卡中的魔法卡，且能作为代价送去墓地
function c9852718.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 定义发动代价函数：从手卡将1张魔法卡送去墓地
function c9852718.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡中是否存在可送去墓地的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9852718.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1张满足过滤条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c9852718.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果处理函数：结束战斗阶段，并使场上表侧表示怪兽的效果直到回合结束时无效
function c9852718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的战斗阶段，使其直接进入战斗阶段的结束步骤（即结束战斗阶段）
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的表侧表示怪兽直到回合结束时效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 场上的表侧表示怪兽直到回合结束时效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
