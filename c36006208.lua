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
-- 过滤满足条件的「彼岸」怪兽（表侧表示且能送入墓地作为费用）
function c36006208.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb1) and c:IsAbleToGraveAsCost()
end
-- 检查是否能通过装备卡影响目标数量，用于判断是否满足送墓条件
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
-- 检查是否能通过装备卡影响目标数量，用于判断是否满足送墓条件
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
-- 过滤满足条件的场上卡（能成为效果对象）
function c36006208.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 设置费用标记，表示需要处理送墓步骤
function c36006208.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 处理效果的发动条件和目标选择，包括送墓和破坏目标的选择
function c36006208.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 获取场上满足条件的「彼岸」怪兽组
			local rg=Duel.GetMatchingGroup(c36006208.filter,tp,LOCATION_MZONE,0,nil)
			-- 获取场上满足条件的可成为效果对象的卡组
			local dg=Duel.GetMatchingGroup(c36006208.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
			return rg:IsExists(c36006208.costfilter,1,nil,rg,dg)
		else
			-- 检查是否存在满足条件的场上卡作为破坏目标
			return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 获取场上满足条件的「彼岸」怪兽组
		local rg=Duel.GetMatchingGroup(c36006208.filter,tp,LOCATION_MZONE,0,nil)
		-- 获取场上满足条件的可成为效果对象的卡组
		local dg=Duel.GetMatchingGroup(c36006208.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
		-- 提示玩家选择要送去墓地的卡
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
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg2=rg:FilterSelect(tp,c36006208.costfilter2,1,1,sc,a,dg)
		sg1:Merge(sg2)
		-- 将选中的卡送去墓地作为费用
		Duel.SendtoGrave(sg1,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上最多3张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,e:GetHandler())
	-- 设置操作信息，表示将要破坏指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理效果的发动，获取目标卡组并进行破坏
function c36006208.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏目标卡组
	Duel.Destroy(sg,REASON_EFFECT)
end
