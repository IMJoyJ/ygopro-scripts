--禁じられた一滴
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，对方不能对应这张卡的发动把原本种类（怪兽·魔法·陷阱）和为这张卡发动而送去墓地的卡相同的卡的效果发动。
-- ①：从自己的手卡·场上把其他卡任意数量送去墓地才能发动。选那个数量的对方场上的效果怪兽。那些怪兽直到回合结束时攻击力变成一半，效果无效化。
function c24299458.initial_effect(c)
	-- ①：从自己的手卡·场上把其他卡任意数量送去墓地才能发动。选那个数量的对方场上的效果怪兽。那些怪兽直到回合结束时攻击力变成一半，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,24299458+EFFECT_COUNT_CODE_OATH)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c24299458.cost)
	e1:SetTarget(c24299458.target)
	e1:SetOperation(c24299458.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回场上正面表示的效果怪兽
function c24299458.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 设置cost标记，用于target阶段判断是否已支付cost
function c24299458.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 判断是否满足发动条件并选择送去墓地的卡，设置连锁限制并记录操作信息
function c24299458.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有正面表示的效果怪兽
	local dg=Duel.GetMatchingGroup(c24299458.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己手牌和场上的卡是否满足送去墓地的条件
		return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) and dg:GetCount()>0
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡送去墓地
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
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(cg,REASON_COST)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，防止对方在发动与送去墓地卡种类相同的卡时进行连锁
		Duel.SetChainLimit(c24299458.chlimit(ctype))
	end
	-- 设置操作信息，记录将要使对方怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,dg,cg:GetCount(),0,0)
end
-- 返回一个连锁限制函数，用于限制对方不能发动与送去墓地卡种类相同的卡
function c24299458.chlimit(ctype)
	return function(e,ep,tp)
		return tp==ep or e:GetHandler():GetOriginalType()&ctype==0
	end
end
-- 处理效果发动，选择对方场上满足条件的怪兽并施加效果
function c24299458.activate(e,tp,eg,ep,ev,re,r,rp)
	local label,count=e:GetLabel()
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择对方场上满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c24299458.filter,tp,0,LOCATION_MZONE,count,count,nil)
	if g:GetCount()==count then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		while tc do
			local atk=tc:GetAttack()
			-- 使目标怪兽的攻击力变为原来的一半
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e1)
			-- 使目标怪兽的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽的效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 使目标怪兽的效果在回合结束时重置
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
