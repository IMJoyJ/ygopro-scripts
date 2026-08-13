--ブービートラップE
-- 效果：
-- ①：丢弃1张手卡才能发动。选自己的手卡·墓地1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c24425055.initial_effect(c)
	-- 对应效果原文：①：丢弃1张手卡才能发动。选自己的手卡·墓地1张永续陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c24425055.cost)
	e1:SetTarget(c24425055.target)
	e1:SetOperation(c24425055.activate)
	c:RegisterEffect(e1)
end
-- 代价筛选函数：判断一张手卡能否作为丢弃代价，并保证丢弃后手卡·墓地中仍有可盖放的永续陷阱卡（该卡自身若是可盖放的永续陷阱也可作为目标）。
function c24425055.filter1(c,tp)
	return c:IsDiscardable() and ((c24425055.filter2(c) and c:IsAbleToGraveAsCost())
		-- 检查自手卡·墓地是否存在至少1张除当前候选丢弃卡以外的、满足可盖放条件的永续陷阱卡，以保证丢弃后仍有对象。
		or Duel.IsExistingMatchingCard(c24425055.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c))
end
-- 筛选函数：判断一张卡是否为永续陷阱卡且当前可以盖放到魔法与陷阱区域。
function c24425055.filter2(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 代价处理函数：进行发动代价的合法性检查并执行丢弃1张手卡的操作（以REASON_COST+REASON_DISCARD为理由）。
function c24425055.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认己方手卡中存在至少1张满足filter1条件的卡，可以作为丢弃代价并保证后续有可盖放的永续陷阱，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24425055.filter1,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 实际执行代价：从己方手卡选择1张满足filter1条件的卡，以“代价丢弃”的理由送去墓地。
	Duel.DiscardHand(tp,c24425055.filter1,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
-- 目标条件判定：确认魔法与陷阱区有空位，且手卡·墓地存在可盖放的永续陷阱卡（若代价已检查则无需重复确认），满足才可发动。
function c24425055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方魔法与陷阱区域当前可用的空格数量，用于判断盖放位置是否足够。
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		return ct>0 and (e:IsCostChecked()
			-- 若尚未进行代价检查，则确认手卡·墓地是否存在至少1张可盖放的永续陷阱卡，保证效果处理时有对象可选。
			or Duel.IsExistingMatchingCard(c24425055.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil))
	end
end
-- 效果处理：从手卡·墓地选择1张符合条件的永续陷阱卡盖放到自己场上；若盖放成功，给该卡附加“本回合可以在盖放回合发动”的效果。
function c24425055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示消息，提示玩家正在选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 筛选并选择1张满足条件的永续陷阱卡：从己方手卡·墓地中，通过王家长眠之谷过滤器排除受王谷影响的卡，再按可盖放条件选择。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24425055.filter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 当成功选取到卡且成功将其盖放到魔陷区时，进入后续处理；否则不执行附加效果。
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 对应效果原文：这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(24425055,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
