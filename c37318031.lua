--R－ライトジャスティス
-- 效果：
-- ①：选自己场上的「元素英雄」卡数量的场上的魔法·陷阱卡破坏。
function c37318031.initial_effect(c)
	-- ①：选自己场上的「元素英雄」卡数量的场上的魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37318031.target)
	e1:SetOperation(c37318031.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断卡片是否为魔法·陷阱卡。
function c37318031.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义筛选函数：判断卡片是否为表侧表示且卡名属于「元素英雄」系列（0x3008）。
function c37318031.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果发动时的目标判定与操作信息设置：在确认发动阶段计算可破坏数量并检查是否有足够对象，满足后确定破坏对象集合。
function c37318031.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 统计自己场上表侧表示且属于「元素英雄」系列的怪兽数量，作为要破坏的魔法·陷阱卡数量。
		local ct=Duel.GetMatchingGroupCount(c37318031.cfilter,tp,LOCATION_MZONE,0,nil)
		e:SetLabel(ct)
		-- 检查场上（双方）是否存在至少ct张可被选择的魔法·陷阱卡（排除本卡），若存在则效果可以发动。
		return Duel.IsExistingMatchingCard(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,c)
	end
	local ct=e:GetLabel()
	-- 获取场上除本卡以外的所有魔法·陷阱卡，作为可能被破坏的候选集合。
	local sg=Duel.GetMatchingGroup(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置本次连锁的处理信息为破坏效果，目标集合为候选的魔法·陷阱卡，数量为ct，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
end
-- 效果处理时的操作：重新统计元素英雄数量，选择对应数量的魔法·陷阱卡并破坏。
function c37318031.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段再次统计自己场上表侧表示且属于「元素英雄」系列的怪兽数量，确定实际要破坏的卡数。
	local ct=Duel.GetMatchingGroupCount(c37318031.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取场上除本卡以外的所有魔法·陷阱卡，作为可供选择的破坏对象集合。
	local g=Duel.GetMatchingGroup(c37318031.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	if g:GetCount()>=ct then
		-- 给玩家弹出选择提示，要求选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 手动展示被选中卡片的对象选择动画，并记录它们为当前效果涉及的对象。
		Duel.HintSelection(sg)
		-- 将选中的卡以效果原因破坏。
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
