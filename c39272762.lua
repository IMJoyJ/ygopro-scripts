--超銀河眼の光子龍
-- 效果：
-- 8星怪兽×3
-- 「银河眼光子龙」作为素材让这张卡超量召唤成功时，这张卡以外的场上表侧表示存在的卡的效果无效。1回合1次，把这张卡1个超量素材取除才能发动。对方场上的超量素材全部取除，这个回合这张卡的攻击力上升取除数量×500的数值。并且，这个回合这张卡在同1次的战斗阶段中可以作出最多有取除数量的攻击。
function c39272762.initial_effect(c)
	-- 添加超量召唤手续，使用8星怪兽3只作为素材进行超量召唤
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- 「银河眼光子龙」作为素材让这张卡超量召唤成功时，这张卡以外的场上表侧表示存在的卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39272762,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c39272762.negcon)
	e1:SetOperation(c39272762.negop)
	c:RegisterEffect(e1)
	-- 检查是否有「银河眼光子龙」作为素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c39272762.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。对方场上的超量素材全部取除，这个回合这张卡的攻击力上升取除数量×500的数值。并且，这个回合这张卡在同1次的战斗阶段中可以作出最多有取除数量的攻击
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(39272762,1))  --"取除素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c39272762.atcost)
	e3:SetTarget(c39272762.attg)
	e3:SetOperation(c39272762.atop)
	c:RegisterEffect(e3)
end
-- 判断是否包含「银河眼光子龙」作为召唤素材
function c39272762.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,93717133) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为超量召唤且包含「银河眼光子龙」作为素材
function c39272762.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
-- 将场上所有表侧表示的卡的效果无效化
function c39272762.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽的效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 检查是否能去除1个超量素材作为代价
function c39272762.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断对方场上有无超量素材
function c39272762.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上有无超量素材
	if chk==0 then return Duel.GetOverlayCount(tp,0,1)~=0 end
end
-- 将对方场上的所有超量素材送去墓地，使自身攻击力上升并获得额外攻击次数
function c39272762.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有超量素材
	local g=Duel.GetOverlayGroup(tp,0,1)
	if g:GetCount()==0 then return end
	-- 将超量素材送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 中断当前效果处理
	Duel.BreakEffect()
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 使自身攻击力上升取除数量×500的数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(g:GetCount()*500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 使自身在同1次的战斗阶段中可以作出最多有取除数量的攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(g:GetCount()-1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
