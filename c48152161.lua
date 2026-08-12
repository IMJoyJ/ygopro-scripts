--神属の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选场上1只效果怪兽，那个效果直到回合结束时无效，自己基本分回复那只怪兽的攻击力的数值。
function c48152161.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只「堕天使」怪兽送去墓地才能发动。选场上1只效果怪兽，那个效果直到回合结束时无效，自己基本分回复那只怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,48152161+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c48152161.cost)
	e1:SetTarget(c48152161.target)
	e1:SetOperation(c48152161.activate)
	c:RegisterEffect(e1)
end
-- 满足条件的「堕天使」怪兽的筛选函数，包括：属于堕天使卡组、是怪兽卡、在手牌或表侧表示怪兽区、可以作为代价送去墓地，并且场上存在效果怪兽可供选择。
function c48152161.costfilter(c)
	return c:IsSetCard(0xef)
		and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在至少1只效果怪兽以供选择。
		and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 发动时的费用处理函数，用于选择并送入墓地的「堕天使」怪兽。
function c48152161.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手牌或场上的「堕天使」怪兽数量不少于1张。
	if chk==0 then return Duel.IsExistingMatchingCard(c48152161.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌或场上选择一张符合条件的「堕天使」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48152161.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡送入墓地作为发动费用。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的目标选择函数，用于确认场上是否存在效果怪兽。
function c48152161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上有至少1只效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息，表示将要无效一个效果怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
-- 效果的处理函数，执行无效怪兽效果并回复LP。
function c48152161.activate(e,tp,eg,ep,ev,re,r,rp)
	local exc=nil
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
	-- 提示玩家选择要无效的效果怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从场上选择一只效果怪兽作为目标。
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 使与该怪兽相关的连锁无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个永续效果，使目标怪兽的效果无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建一个永续效果，使目标怪兽的效果在回合结束时解除无效状态。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 立即刷新场上受影响的卡牌状态。
		Duel.AdjustInstantly(tc)
		local atk=tc:GetAttack()
		if atk>0 then
			-- 使自己回复该怪兽攻击力数值的LP。
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
