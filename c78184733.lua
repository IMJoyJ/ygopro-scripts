--エンタメ・フラッシュ
-- 效果：
-- ①：自己场上有「娱乐伙伴」怪兽存在的场合才能发动。对方场上的表侧攻击表示怪兽全部变成守备表示，那些怪兽直到下个回合的结束时不能把表示形式变更。
function c78184733.initial_effect(c)
	-- ①：自己场上有「娱乐伙伴」怪兽存在的场合才能发动。对方场上的表侧攻击表示怪兽全部变成守备表示，那些怪兽直到下个回合的结束时不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c78184733.condition)
	e1:SetTarget(c78184733.target)
	e1:SetOperation(c78184733.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「娱乐伙伴」怪兽
function c78184733.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 发动条件：检查自己场上是否存在「娱乐伙伴」怪兽
function c78184733.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「娱乐伙伴」怪兽
	return Duel.IsExistingMatchingCard(c78184733.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧攻击表示且可以变更表示形式的怪兽
function c78184733.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果发动：检查对方场上是否存在符合条件的怪兽，并设置改变表示形式的操作信息
function c78184733.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78184733.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c78184733.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将符合条件的怪兽变成守备表示，并使其直到下个回合结束时不能变更表示形式
function c78184733.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前对方场上所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c78184733.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		local tc=g:GetFirst()
		while tc do
			-- 那些怪兽直到下个回合的结束时不能把表示形式变更。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
