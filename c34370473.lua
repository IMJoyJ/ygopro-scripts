--グリフォンの羽根帚
-- 效果：
-- 破坏自己场上所有魔法·陷阱卡。自己回复被破坏的卡数量×500基本分。
function c34370473.initial_effect(c)
	-- 破坏自己场上所有魔法·陷阱卡。自己回复被破坏的卡数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34370473.target)
	e1:SetOperation(c34370473.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：只要这张卡是魔法卡或陷阱卡就满足条件。
function c34370473.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时的目标处理阶段：确认能否发动，并设置效果处理时破坏与回复的信息。
function c34370473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在时点检查时，确认自己场上除这张卡以外是否存在至少1张可以破坏的魔法·陷阱卡；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34370473.filter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 取得自己场上除这张卡以外所有魔法·陷阱卡，作为后续破坏的对象集合。
	local g=Duel.GetMatchingGroup(c34370473.filter,tp,LOCATION_ONFIELD,0,c)
	-- 将上述集合登记为破坏效果的操作信息，数量为集合中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 将回复效果的操作信息登记为：预计回复的数值为这些卡的数量×500。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*500)
end
-- 效果处理时的实际操作：选取自己场上除自身以外的所有魔法·陷阱卡并破坏，然后根据实际破坏数量回复基本分。
function c34370473.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取自己场上除这张卡自身以外的所有魔法·陷阱卡（排除与效果关联的此卡）。
	local g=Duel.GetMatchingGroup(c34370473.filter,tp,LOCATION_ONFIELD,0,aux.ExceptThisCard(e))
	-- 将这些卡以效果原因破坏，并记录实际被破坏的数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 回复玩家基本分，回复量为实际破坏数量×500。
	Duel.Recover(tp,ct*500,REASON_EFFECT)
end
