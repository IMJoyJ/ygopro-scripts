--エクシーズ・ブロック
-- 效果：
-- ①：对方把怪兽的效果发动时，把自己场上1个超量素材取除才能发动。那个发动无效并破坏。
function c44487250.initial_effect(c)
	-- 创建效果，设置效果分类为无效和破坏，类型为发动，触发事件为连锁发动，条件为c44487250.condition，代价为c44487250.cost，目标为c44487250.target，效果处理为c44487250.activate
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
-- 效果发动时的条件判断，对方怪兽发动效果且该连锁可以被无效
function c44487250.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽发动效果且该连锁可以被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于检查是否能移除指定数量的超量素材
function c44487250.only_filter(c,onlyc,tp)
	local require_count=c==onlyc and 2 or 1
	return c:CheckRemoveOverlayCard(tp,require_count,REASON_COST)
end
-- 效果发动时的代价处理，根据手牌中是否有陷阱发动效果进行不同判断
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
				-- 检查场上是否存在满足条件的怪兽，用于特殊处理特定陷阱卡
				return Duel.IsExistingMatchingCard(c44487250.only_filter,tp,LOCATION_MZONE,0,1,nil,available_fromhand_effects[1]:GetHandler(),tp)
			else
				-- 检查是否能移除1个超量素材作为代价
				return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
			end
		else
			-- 检查是否能移除1个超量素材作为代价
			return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST)
		end
	end
	-- 执行移除1个超量素材的操作
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 设置效果处理时的操作信息，包括无效和破坏
function c44487250.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数，使连锁无效并破坏对应怪兽
function c44487250.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁无效并判断目标怪兽是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对应怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
