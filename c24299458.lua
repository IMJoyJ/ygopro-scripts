--禁じられた一滴
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，对方不能对应这张卡的发动把原本种类（怪兽·魔法·陷阱）和为这张卡发动而送去墓地的卡相同的卡的效果发动。
-- ①：从自己的手卡·场上把其他卡任意数量送去墓地才能发动。选那个数量的对方场上的效果怪兽。那些怪兽直到回合结束时攻击力变成一半，效果无效化。
function c24299458.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，对方不能对应这张卡的发动把原本种类（怪兽·魔法·陷阱）和为这张卡发动而送去墓地的卡相同的卡的效果发动。①：从自己的手卡·场上把其他卡任意数量送去墓地才能发动。选那个数量的对方场上的效果怪兽。那些怪兽直到回合结束时攻击力变成一半，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,24299458+EFFECT_COUNT_CODE_OATH)
	-- 设置效果发动条件为伤害步骤限制：只能在伤害步骤且尚未进行伤害计算时发动（即不能在伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c24299458.cost)
	e1:SetTarget(c24299458.target)
	e1:SetOperation(c24299458.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：选择对方场上表侧表示的效果怪兽。
function c24299458.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 代价判定阶段：先设置标签100表示代价处理已进入下一步；若仅检查能否发动则返回true（实际可送墓的卡在目标选择时检查）。
function c24299458.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 发动时选择：获取对方场上表侧表示效果怪兽集合；检查是否存在可送墓的卡且对方有怪兽；由玩家从手卡·场上（除本卡外）选择任意数量（1~对方效果怪兽数）可送墓的卡；计算这些卡原本种类（怪兽/魔法/陷阱）的并集；将选卡作为代价送去墓地；设置连锁限制（对方不能发动原种类与送墓卡相同的卡的效果）；登记无效效果的操作信息。
function c24299458.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有表侧表示效果怪兽，作为可能被选为对象的集合（后续用于数量限制与选择）。
	local dg=Duel.GetMatchingGroup(c24299458.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己手卡·场上是否存在除本卡以外可作为代价送去墓地的卡，且对方场上有至少1只表侧效果怪兽，满足这两条件才可发动。
		return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) and dg:GetCount()>0
	end
	-- 给玩家显示选择提示“请选择要送去墓地的卡”，用于引导选择代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 由玩家选择1张到对方场上效果怪兽数量张的自己手卡·场上（除本卡外）可作为代价的卡，并作为本次效果的代价对象。
	local cg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,dg:GetCount(),e:GetHandler())
	local tc=cg:GetFirst()
	local ctype=0
	while tc do
		for i,type in ipairs({TYPE_MONSTER,TYPE_SPELL,TYPE_TRAP}) do
			if tc:GetOriginalType()&type~=0 then
				ctype=ctype|type
			end
		end
		tc=cg:GetNext()
	end
	e:SetLabel(0,cg:GetCount())
	-- 将选择的卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(cg,REASON_COST)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制：对方不能连锁发动原本种类与本次送墓的卡相同的卡的效果（以ctype记录种类并集）。
		Duel.SetChainLimit(c24299458.chlimit(ctype))
	end
	-- 登记本连锁的操作信息：效果分类为无效（CATEGORY_DISABLE），可能影响的对象是对方场上所有表侧效果怪兽，数量为送墓卡数量，用于后续发动检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,dg,cg:GetCount(),0,0)
end
-- 定义连锁限制函数：返回一个闭包，若尝试连锁的玩家是己方则允许；否则若对方发动的效果原本种类与送墓卡种类有交集则禁止连锁。
function c24299458.chlimit(ctype)
	return function(e,ep,tp)
		return tp==ep or e:GetHandler():GetOriginalType()&ctype==0
	end
end
-- 效果处理时：按先前送墓数量从对方场上选择相应数量的表侧效果怪兽；对每只目标怪兽：将其攻击力变为原攻击力的一半（向上取整）、使其效果无效化（包括卡面效果无效和效果发动无效化），这些状态持续到回合结束。
function c24299458.activate(e,tp,eg,ep,ev,re,r,rp)
	local label,count=e:GetLabel()
	-- 给玩家显示选择提示“请选择要操作的卡”，用于选择对方场上要无效的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从对方场上的表侧效果怪兽中选择正好count张（count为送墓卡数量）作为效果处理对象，不取对象选择。
	local g=Duel.SelectMatchingCard(tp,c24299458.filter,tp,0,LOCATION_MZONE,count,count,nil)
	if g:GetCount()==count then
		-- 手动显示被选怪兽的选中动画，并将这些卡记录为本效果关联的对象。
		Duel.HintSelection(g)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			local atk=tc:GetAttack()
			-- 对应原文“那些怪兽直到回合结束时攻击力变成一半”：给目标怪兽注册效果，将其攻击力最终值设为当前攻击力的一半（向上取整），持续到回合结束。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e1)
			-- 将与目标怪兽相关的连锁效果无效化（用于无效该怪兽及其相关发动效果），状态持续到回合结束。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 对应原文“效果无效化”：给目标怪兽注册EFFECT_DISABLE效果，使其卡面效果文本无效化（怪兽效果无效），直到回合结束。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 对应原文“效果无效化”：给目标怪兽注册EFFECT_DISABLE_EFFECT效果，使该怪兽适用的效果无效化（含已适用的效果），持续到回合结束。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			tc=g:GetNext()
		end
	end
end
