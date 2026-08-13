--妨害電波
-- 效果：
-- 双方场上存在的同调怪兽全部变成守备表示，结束阶段时场上表侧表示存在的同调怪兽全部回到额外卡组。
function c39440937.initial_effect(c)
	-- 双方场上存在的同调怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39440937.target)
	e1:SetOperation(c39440937.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的怪兽：表侧攻击表示、同调怪兽、且可以变更表示形式。
function c39440937.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsType(TYPE_SYNCHRO) and c:IsCanChangePosition()
end
-- 发动时：若存在符合条件的同调怪兽，则获取双方怪兽区所有这样的怪兽，并设置本次操作信息为变更表示形式。
function c39440937.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：检查双方怪兽区是否存在至少1只表侧攻击表示且可变更表示形式的同调怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方怪兽区所有满足filter的同调怪兽，用于设置操作信息。
	local g=Duel.GetMatchingGroup(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果改变表示形式，对象为上述怪兽，数量为g的数量；供后续处理与连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：取得双方怪兽区符合条件的同调怪兽并全部变为表侧守备表示；若变更成功，再为发动者注册一个结束阶段时处理返回额外卡组的效果。
function c39440937.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得双方怪兽区所有符合条件的同调怪兽，作为本次改变表示形式的对象。
	local g=Duel.GetMatchingGroup(c39440937.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 如果存在符合条件的怪兽，且成功将它们全部变为表侧守备表示，则继续执行后续的结束阶段效果注册。
	if g:GetCount()>0 and Duel.ChangePosition(g,POS_FACEUP_DEFENSE)~=0 then
		-- 结束阶段时场上表侧表示存在的同调怪兽全部回到额外卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c39440937.tdcon)
		e1:SetOperation(c39440937.tdop)
		-- 将新建的结束阶段持续效果注册给当前玩家tp，使其在结束阶段可触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选结束阶段要送回额外卡组的怪兽：表侧表示的同调怪兽，且可以被送回额外卡组。
function c39440937.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 结束阶段效果的触发条件：双方怪兽区是否存在至少1只表侧表示且可送回额外卡组的同调怪兽。
function c39440937.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在至少1只满足tdfilter的同调怪兽，以决定结束阶段是否执行处理。
	return Duel.IsExistingMatchingCard(c39440937.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 结束阶段处理：获取双方怪兽区所有表侧表示且可回额外卡组的同调怪兽，并将其送回持有者的额外卡组。
function c39440937.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方怪兽区所有满足tdfilter的同调怪兽，作为结束阶段返回额外卡组的对象。
	local g=Duel.GetMatchingGroup(c39440937.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将这些同调怪兽以效果原因送回持有者的额外卡组（额外怪兽进入额外卡组），实现『回到额外卡组』。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
