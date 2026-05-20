--澱神アポピス
-- 效果：
-- ①：自己·对方的主要阶段才能把这张卡发动。这张卡变成通常怪兽（爬虫类族·地·6星·攻2000/守2200）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，自己场上有其他的永续陷阱卡存在的场合，可以让最多有那个数量的对方场上的表侧表示卡的效果直到回合结束时无效。
function c85888377.initial_effect(c)
	-- ①：自己·对方的主要阶段才能把这张卡发动。这张卡变成通常怪兽（爬虫类族·地·6星·攻2000/守2200）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c85888377.condition)
	e1:SetTarget(c85888377.target)
	e1:SetOperation(c85888377.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件检查函数
function c85888377.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义效果发动的目标选择与合法性检查函数
function c85888377.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 并检查自己场上的怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查玩家是否能将该卡作为特定属性、种族、攻守和等级的陷阱怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,85888377,0,TYPES_NORMAL_TRAP_MONSTER,2000,2200,6,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 设置特殊召唤的操作信息，表明此效果包含将自身特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义过滤函数，用于筛选自己场上表侧表示的永续陷阱卡
function c85888377.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
end
-- 定义效果处理函数，并检查此卡是否仍与效果关联以及是否仍能特殊召唤
function c85888377.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		-- 或者无法将该卡作为特定属性、种族、攻守和等级的陷阱怪兽特殊召唤，则结束效果处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,85888377,0,TYPES_NORMAL_TRAP_MONSTER,2000,2200,6,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	-- 将此卡特殊召唤到怪兽区域，若特殊召唤成功则继续处理后续效果
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		-- 计算自己场上除这张卡以外的其他表侧表示永续陷阱卡数量
		local ct=Duel.GetMatchingGroupCount(c85888377.filter,tp,LOCATION_ONFIELD,0,c)
		-- 获取对方场上所有表侧表示且可被无效的卡片
		local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
		-- 若自己场上有其他永续陷阱卡且对方场上有可无效的卡，则由玩家选择是否发动无效效果
		if ct>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(85888377,0)) then  --"是否选对方的卡无效？"
			-- 中断当前效果处理，使后续的无效处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要无效效果的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sg=g:Select(tp,1,ct,nil)
			-- 在场上对选中的卡片进行闪烁提示
			Duel.HintSelection(sg)
			-- 遍历选中的卡片组，对每张卡片进行效果无效的处理
			for tc in aux.Next(sg) do
				-- 使与目标卡片相关的连锁效果无效化
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				-- 让最多有那个数量的对方场上的表侧表示卡的效果直到回合结束时无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e2)
				if tc:IsType(TYPE_TRAPMONSTER) then
					local e3=e1:Clone()
					e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					tc:RegisterEffect(e3)
				end
			end
		end
	end
end
