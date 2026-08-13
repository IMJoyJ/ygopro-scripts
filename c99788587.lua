--爆導索
-- 效果：
-- ①：和这张卡相同纵列全部有卡存在的场合才能把盖放的这张卡发动。那个纵列的卡全部破坏。
function c99788587.initial_effect(c)
	-- ①：和这张卡相同纵列全部有卡存在的场合才能把盖放的这张卡发动。那个纵列的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c99788587.condition)
	e1:SetTarget(c99788587.target)
	e1:SetOperation(c99788587.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查此卡所在纵列（怪兽区域和魔法陷阱区域）的所有区域是否都有卡存在，且该效果属于魔法陷阱卡的发动，两者均满足时才允许发动。
function c99788587.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAllColumn() and e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 发动时的目标处理：本效果不取对象；chk==0时直接返回true表示可以发动；随后记录本卡所在列号，取得与本卡同纵列的其他卡片作为可能被破坏的集合，并向系统登记破坏操作信息。
function c99788587.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将本卡所在的实际列号加1后存入效果Label，用0作为未设置标记，以便在效果处理时能正确还原列号。
	e:SetLabel(aux.GetColumn(c)+1)
	local g=e:GetHandler():GetColumnGroup()
	-- 向系统登记这次破坏操作：预定破坏的卡片为同纵列卡片组g，数量为g的卡片数，用于让其他卡（如星尘龙）能检测到此次效果破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义筛选函数opfilter：用于在后续处理中判断一张卡是否属于要破坏的指定纵列。
function c99788587.opfilter(c,col)
	-- 返回卡片c的列号是否与目标列号col相等，只保留同一纵列内的卡片。
	return aux.GetColumn(c)==col
end
-- 效果处理：读取之前保存的列号标签，若有效则还原为实际列号；然后筛选场上该纵列除本卡以外的所有卡片，若有则将其全部破坏。
function c99788587.activate(e,tp,eg,ep,ev,re,r,rp)
	local col=e:GetLabel()
	if col>0 then
		col=col-1
		-- 检索场上所有满足opfilter条件且列号等于目标列号的卡，并通过aux.ExceptThisCard(e)排除本卡，得到要破坏的卡片集合g。
		local g=Duel.GetMatchingGroup(c99788587.opfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e),col)
		if g:GetCount()>0 then
			-- 以效果原因（REASON_EFFECT）将集合g中的卡片全部破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
