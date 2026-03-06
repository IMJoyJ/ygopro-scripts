--ブービートラップE
-- 效果：
-- ①：丢弃1张手卡才能发动。选自己的手卡·墓地1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c24425055.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡才能发动。选自己的手卡·墓地1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c24425055.cost)
	e1:SetTarget(c24425055.target)
	e1:SetOperation(c24425055.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查玩家手牌中是否存在可丢弃且满足filter2条件的卡，或手牌+墓地存在满足filter2条件的卡。
function c24425055.filter1(c,tp)
	return c:IsDiscardable() and ((c24425055.filter2(c) and c:IsAbleToGraveAsCost())
		-- 规则层面作用：检查手牌或墓地是否存在满足filter2条件的卡。
		or Duel.IsExistingMatchingCard(c24425055.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c))
end
-- 规则层面作用：过滤出类型为陷阱卡且为永续类型的卡，并且可以盖放。
function c24425055.filter2(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 规则层面作用：执行丢弃手卡的代价，丢弃1张满足filter1条件的手卡。
function c24425055.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足丢弃手卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c24425055.filter1,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 规则层面作用：执行丢弃手卡操作，丢弃1张满足filter1条件的手卡。
	Duel.DiscardHand(tp,c24425055.filter1,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
-- 规则层面作用：判断是否满足盖放条件，包括场上空位和是否存在满足filter2条件的卡。
function c24425055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 规则层面作用：获取玩家场上可用的魔陷区空位数量。
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		return ct>0 and (e:IsCostChecked()
			-- 规则层面作用：检查手牌或墓地是否存在满足filter2条件的卡。
			or Duel.IsExistingMatchingCard(c24425055.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil))
	end
end
-- 规则层面作用：选择并盖放一张满足条件的永续陷阱卡，使其在盖放回合也能发动。
function c24425055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 规则层面作用：从手牌或墓地中选择一张满足filter2条件的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24425055.filter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 规则层面作用：将选中的卡盖放到场上。
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 效果原文内容：这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(24425055,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
