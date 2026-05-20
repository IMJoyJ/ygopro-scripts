--帝王の轟毅
-- 效果：
-- ①：把自己场上1只5星以上的通常召唤的表侧表示怪兽解放，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。那之后，自己从卡组抽1张。
-- ②：自己主要阶段把墓地的这张卡除外，宣言1个属性才能发动。场上的全部表侧表示怪兽直到回合结束时变成宣言的属性。
function c5795980.initial_effect(c)
	-- ①：把自己场上1只5星以上的通常召唤的表侧表示怪兽解放，以场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c5795980.cost)
	e1:SetTarget(c5795980.target)
	e1:SetOperation(c5795980.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，宣言1个属性才能发动。场上的全部表侧表示怪兽直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5795980,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c5795980.attg)
	e2:SetOperation(c5795980.atop)
	c:RegisterEffect(e2)
end
-- 设置代价标记，用于在target中实际处理解放
function c5795980.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤自己场上5星以上的通常召唤的表侧表示怪兽
function c5795980.cfilter(c,ec,tp)
	if c:IsFacedown() or not c:IsLevelAbove(5) or not c:IsSummonType(SUMMON_TYPE_NORMAL) then return false end
	-- 检查场上是否存在除自身和解放怪兽以外的可无效的卡
	return Duel.IsExistingTarget(c5795980.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c,ec)
end
-- 过滤可作为无效目标的卡
function c5795980.tgfilter(c,tc,ec)
	-- 判定卡片是否可被无效，且不是解放怪兽的装备卡，也不是本卡自身
	return aux.NegateAnyFilter(c) and c:GetEquipTarget()~=tc and c~=ec
end
-- ①号效果的发动准备与目标选择
function c5795980.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查当前指向的对象是否仍在场上且可被无效，且不是本卡自身
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) and chkc~=c end
	if chk==0 then
		-- 检查玩家当前是否可以抽卡
		if not Duel.IsPlayerCanDraw(tp,1) then return false end
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在可作为解放代价的怪兽
			return Duel.CheckReleaseGroup(tp,c5795980.cfilter,1,c,c,tp)
		else
			-- 检查场上是否存在可作为无效对象的目标
			return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的怪兽解放
		local sg=Duel.SelectReleaseGroup(tp,c5795980.cfilter,1,1,c,c,tp)
		-- 将选择的怪兽解放作为发动代价
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置连锁信息，表示该效果包含无效卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置连锁信息，表示该效果包含抽卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①号效果的实际处理逻辑
function c5795980.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取已选择的无效对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该卡相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		-- 产生时点中断，使后续的抽卡处理不与无效处理同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②号效果的发动准备与属性宣言
function c5795980.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(rc)
end
-- ②号效果的实际处理逻辑
function c5795980.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上全部表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 场上的全部表侧表示怪兽直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
