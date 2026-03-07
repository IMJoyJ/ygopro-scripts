--魔法の歯車
-- 效果：
-- ①：把自己场上3张表侧表示的「古代的机械」卡送去墓地才能发动。从手卡以及卡组各把最多1只「古代的机械巨人」无视召唤条件特殊召唤。那之后，自己场上有「古代的机械巨人」以外的怪兽存在的场合，那些怪兽全部破坏。这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
function c313513.initial_effect(c)
	-- 记录此卡具有「古代的机械巨人」这张卡的卡片密码
	aux.AddCodeList(c,83104731)
	-- ①：把自己场上3张表侧表示的「古代的机械」卡送去墓地才能发动。从手卡以及卡组各把最多1只「古代的机械巨人」无视召唤条件特殊召唤。那之后，自己场上有「古代的机械巨人」以外的怪兽存在的场合，那些怪兽全部破坏。这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c313513.cost)
	e1:SetTarget(c313513.target)
	e1:SetOperation(c313513.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否有表侧表示的「古代的机械」卡且能作为cost送去墓地
function c313513.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7) and c:IsAbleToGraveAsCost()
end
-- 效果cost处理：检查场上是否存在3张满足条件的卡并选择送去墓地
function c313513.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上满足条件的卡组
	local tg=Duel.GetMatchingGroup(c313513.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		e:SetLabel(1)
		-- 检查场上是否存在3张满足条件的卡
		return tg:CheckSubGroup(aux.mzctcheck,3,3,tp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择3张满足条件的卡
	local g=tg:SelectSubGroup(tp,aux.mzctcheck,false,3,3,tp)
	-- 将选中的卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：检查是否为「古代的机械巨人」且能特殊召唤
function c313513.filter(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果target处理：检查手卡和卡组是否存在「古代的机械巨人」且能特殊召唤
function c313513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家怪兽区是否为空
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		-- 检查手卡和卡组是否存在至少1只「古代的机械巨人」
		return Duel.IsExistingMatchingCard(c313513.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置效果处理信息：特殊召唤1只「古代的机械巨人」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数：检查场上怪兽是否为「古代的机械巨人」以外的怪兽
function c313513.dfilter(c)
	return c:IsFacedown() or not c:IsCode(83104731)
end
-- 过滤函数：检查选中的卡是否来自不同位置
function c313513.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- 效果activate处理：特殊召唤「古代的机械巨人」并破坏场上其他怪兽
function c313513.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算玩家可特殊召唤的怪兽数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 获取手卡和卡组中满足条件的「古代的机械巨人」
	local g=Duel.GetMatchingGroup(c313513.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft>0 and g:GetCount()>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectSubGroup(tp,c313513.fselect,false,1,ft)
		-- 特殊召唤选中的卡
		if sg and Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)>0 then
			-- 获取场上满足条件的怪兽
			local dg=Duel.GetMatchingGroup(c313513.dfilter,tp,LOCATION_MZONE,0,nil)
			if dg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 破坏场上满足条件的怪兽
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
	-- ①：把自己场上3张表侧表示的「古代的机械」卡送去墓地才能发动。从手卡以及卡组各把最多1只「古代的机械巨人」无视召唤条件特殊召唤。那之后，自己场上有「古代的机械巨人」以外的怪兽存在的场合，那些怪兽全部破坏。这个效果的发动后，用自己回合计算的2回合内，自己不能通常召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_SELF_TURN+RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(1,0)
	-- 注册不能通常召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 注册不能设置怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
