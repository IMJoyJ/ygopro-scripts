--命の綱
-- 效果：
-- 当自己的怪兽因战斗送去墓地时，将手卡全部丢弃发动这张卡，那只怪兽的攻击力上升800，并且特殊召唤上场。
function c93382620.initial_effect(c)
	-- 当自己的怪兽因战斗送去墓地时，将手卡全部丢弃发动这张卡，那只怪兽的攻击力上升800，并且特殊召唤上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCost(c93382620.cost)
	e1:SetTarget(c93382620.target)
	e1:SetOperation(c93382620.activate)
	c:RegisterEffect(e1)
end
-- 检查并执行发动代价：将手卡全部丢弃。
function c93382620.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家的手牌卡片组。
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return g:GetCount()>0 and g:FilterCount(Card.IsDiscardable,nil)==g:GetCount()
	end
	-- 获取玩家的手牌卡片组。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将手牌全部作为代价丢弃送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤因战斗破坏送去自己墓地且可以特殊召唤、可以作为效果对象的怪兽。
function c93382620.filter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 检查发动条件并选择因战斗破坏送去墓地的怪兽作为效果对象。
function c93382620.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c93382620.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c93382620.filter,1,nil,e,tp) end
	local g=eg:Filter(c93382620.filter,nil,e,tp)
	-- 将选中的怪兽设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽并使其攻击力上升800。
function c93382620.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并尝试将其以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽的攻击力上升800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
