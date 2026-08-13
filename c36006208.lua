--彼岸の沈溺
-- 效果：
-- ①：把自己场上2只表侧表示的「彼岸」怪兽送去墓地，以场上最多3张卡为对象才能发动。那些卡破坏。
function c36006208.initial_effect(c)
	-- ①：把自己场上2只表侧表示的「彼岸」怪兽送去墓地，以场上最多3张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c36006208.cost)
	e1:SetTarget(c36006208.target)
	e1:SetOperation(c36006208.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为代价送去墓地表侧表示的「彼岸」怪兽。
function c36006208.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb1) and c:IsAbleToGraveAsCost()
end
-- 选取第一只代价怪兽时，检查能否在剩余候选怪兽中再选一只，并确保代价涉及的卡与破坏对象重叠后，仍有至少1张可破坏的卡。
function c36006208.costfilter(c,rg,dg)
	local a=0
	if dg:IsContains(c) then a=1 end
	if c:GetEquipCount()==0 then return rg:IsExists(c36006208.costfilter2,1,c,a,dg) end
	local eg=c:GetEquipGroup()
	local tc=eg:GetFirst()
	while tc do
		if dg:IsContains(tc) then a=a+1 end
		tc=eg:GetNext()
	end
	return rg:IsExists(c36006208.costfilter2,1,c,a,dg)
end
-- 选取第二只代价怪兽时，累计代价涉及的卡与破坏对象重叠数，确保送墓后仍有至少1张可破坏的卡。
function c36006208.costfilter2(c,a,dg)
	if dg:IsContains(c) then a=a+1 end
	if c:GetEquipCount()==0 then return dg:GetCount()-a>=1 end
	local eg=c:GetEquipGroup()
	local tc=eg:GetFirst()
	while tc do
		if dg:IsContains(tc) then a=a+1 end
		tc=eg:GetNext()
	end
	return dg:GetCount()-a>=1
end
-- 判断场上卡片能否成为此效果的对象。
function c36006208.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 代价函数：设置标签为1，标记后续在目标选择阶段执行送墓代价。
function c36006208.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 目标选择函数：先选择两只「彼岸」怪兽作为代价送去墓地，再选择场上最多3张卡作为破坏对象。
function c36006208.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 获取自己场上可作为代价的表侧表示「彼岸」怪兽组。
			local rg=Duel.GetMatchingGroup(c36006208.filter,tp,LOCATION_MZONE,0,nil)
			-- 获取场上可作为此效果对象的所有卡（排除本卡）。
			local dg=Duel.GetMatchingGroup(c36006208.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
			return rg:IsExists(c36006208.costfilter,1,nil,rg,dg)
		else
			-- 检查场上是否存在至少1张可成为对象的卡（在无需处理代价的再次检查中使用）。
			return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 获取自己场上可作为代价的表侧表示「彼岸」怪兽组。
		local rg=Duel.GetMatchingGroup(c36006208.filter,tp,LOCATION_MZONE,0,nil)
		-- 获取场上可作为此效果对象的所有卡（排除本卡）。
		local dg=Duel.GetMatchingGroup(c36006208.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
		-- 弹出“请选择要送去墓地的卡”的提示，用于选择第一只代价怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg1=rg:FilterSelect(tp,c36006208.costfilter,1,1,nil,rg,dg)
		local sc=sg1:GetFirst()
		local a=0
		if dg:IsContains(sc) then a=1 end
		if sc:GetEquipCount()>0 then
			local eqg=sc:GetEquipGroup()
			local tc=eqg:GetFirst()
			while tc do
				if dg:IsContains(tc) then a=a+1 end
				tc=eqg:GetNext()
			end
		end
		-- 弹出“请选择要送去墓地的卡”的提示，用于选择第二只代价怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg2=rg:FilterSelect(tp,c36006208.costfilter2,1,1,sc,a,dg)
		sg1:Merge(sg2)
		-- 将选择的两只「彼岸」怪兽作为代价送去墓地。
		Duel.SendtoGrave(sg1,REASON_COST)
	end
	-- 弹出“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上最多3张卡作为破坏对象（本卡不能选择）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,e:GetHandler())
	-- 设置操作信息：登记将要破坏的对象卡及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：从连锁信息中取得对象，破坏仍与效果相关的卡。
function c36006208.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果相关的对象卡全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
