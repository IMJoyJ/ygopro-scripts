--エクシーズ・ブロック
-- 效果：
-- ①：对方把怪兽的效果发动时，把自己场上1个超量素材取除才能发动。那个发动无效并破坏。
function c44487250.initial_effect(c)
	-- ①：对方把怪兽的效果发动时，把自己场上1个超量素材取除才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c44487250.condition)
	e1:SetCost(c44487250.cost)
	e1:SetTarget(c44487250.target)
	e1:SetOperation(c44487250.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：仅在对方玩家发动怪兽效果，且该效果能够被无效时，此卡才能发动。
function c44487250.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断具体条件：对方发动的效果属于怪兽效果（rp==1-tp，re:IsActiveType(TYPE_MONSTER)），并且当前连锁可以被无效（Duel.IsChainNegatable）。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 筛选可作为代价的超量怪兽：若该怪兽就是赋予此卡从手牌发动效果的那张卡，则需要额外取除1个素材，即共需取除2个素材；否则只需取除1个素材。
function c44487250.only_filter(c,onlyc,tp)
	local require_count=c==onlyc and 2 or 1
	return c:CheckRemoveOverlayCard(tp,require_count,REASON_COST)
end
-- 代价处理整体：通常从自己场上取除1个超量素材；若这张卡在手牌且通过特定效果获得从手牌发动能力时，会根据具体来源检查额外代价，并在最后实际移除素材。
function c44487250.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		if c:IsLocation(LOCATION_HAND) then
			local fromhand_effects={c:IsHasEffect(EFFECT_TRAP_ACT_IN_HAND)}
			local available_fromhand_effects={}
			for _,te in ipairs(fromhand_effects) do
				local cost=te:GetCost()
				if te:CheckCountLimit(tp) and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0,e)) then
					table.insert(available_fromhand_effects,te)
				end
			end
			if #available_fromhand_effects==1 and available_fromhand_effects[1]:GetValue()==85551711 then
				-- 检查自己场上是否存在满足条件的超量怪兽：若场上存在那张特定的从手牌发动效果来源卡，则要求它能取除2个素材；否则要求能取除1个素材，以满足从手牌发动时的追加代价。
				return Duel.IsExistingMatchingCard(c44487250.only_filter,tp,LOCATION_MZONE,0,1,nil,available_fromhand_effects[1]:GetHandler(),tp)
			else
				-- 在手牌发动情况下，若不存在需要特判的特定效果，则按通常代价检查：自己场上能否取除1个超量素材。
				return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
			end
		else
			-- 当此卡不在手牌（即已在场上发动）时，按通常代价检查：自己场上能否取除1个超量素材。
			return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
		end
	end
	-- 实际支付代价：从自己场上的超量怪兽上取除1个超量素材（REASON_COST）。
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 目标处理：在发动时声明本效果将进行无效并破坏；如果对方发动效果的那只怪兽可被破坏且与该效果仍有联系，则同时为破坏设置操作信息。
function c44487250.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的效果（eg对应的事件对象）标记为需要无效化（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若该效果怪兽可被破坏且仍与效果关联，则将其标记为破坏对象（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理整体：先尝试无效对方怪兽效果的发动，若无效成功且该怪兽卡仍与效果有关联，则将其破坏。
function c44487250.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，且发动效果的那张怪兽卡仍然存在/与该效果保持关联，以决定是否执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动效果的那张怪兽卡破坏，破坏原因为效果（REASON_EFFECT）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
