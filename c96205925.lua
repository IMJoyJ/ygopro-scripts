--異解△福音
-- 效果：
-- 从自己的卡组上面·墓地把合计5张卡里侧除外才能把这张卡发动。这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「异解△」怪兽召唤。
-- ②：自己主要阶段才能发动。自己场上1只原本等级是4星以下的「异解△」怪兽里侧除外，自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 从自己的卡组上面·墓地把合计5张卡里侧除外才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「异解△」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"使用「异解△福音」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤适用的对象为「异解△」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1ed))
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。自己场上1只原本等级是4星以下的「异解△」怪兽里侧除外，自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 发动Cost：从自己的卡组上面·墓地把合计5张卡里侧除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中可里侧除外作为Cost的卡片数量
	local dct=Duel.GetMatchingGroupCount(Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK,0,nil,POS_FACEDOWN)
	-- 检查卡组与墓地合计是否至少有5张卡可以里侧除外作为Cost
	if chk==0 then return dct>=5 or dct<5 and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,5-dct,nil,POS_FACEDOWN) end
	if dct>5 then dct=5 end
	local gg=Group.CreateGroup()
	-- 若卡组数量充足且墓地有可除外的卡，判断是否选择除外墓地的卡
	if dct>=5 and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,1,nil,POS_FACEDOWN)
		-- 玩家选择是否除外墓地的卡来发动
		and Duel.SelectYesNo(tp,aux.Stringid(id,0))  --"是否除外墓地的卡来发动？"
		or dct<5 then
		local st=dct
		if st==5 then st=4 end
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从墓地选择指定数量的卡里侧除外
		gg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,5-st,5,nil,POS_FACEDOWN)
		-- 显示选中的墓地卡片
		Duel.HintSelection(gg)
	end
	if gg:GetCount()>0 then
		dct=5-gg:GetCount()
	end
	-- 获取卡组顶端补足合计5张所需数量的卡
	local dg=Duel.GetDecktopGroup(tp,dct)
	if dct<5 then
		dg:Merge(gg)
	end
	-- 使后续除外操作不触发洗切卡组检查
	Duel.DisableShuffleCheck()
	-- 将选中的卡片作为Cost以里侧表示除外
	if Duel.Remove(dg,POS_FACEDOWN,REASON_COST)~=0 then
		-- 遍历被除外的卡片并给里侧除外的卡添加客户端标记
		for tc in aux.Next(dg) do
			if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「异解△福音」发动被里侧除外"
			end
		end
	end
end
-- 过滤条件：自己场上原本等级4星以下的「异解△」怪兽
function s.rmfilter(c,tp,chk)
	return c:IsFaceupEx() and c:IsSetCard(0x1ed) and c:GetOriginalLevel()>0 and c:GetOriginalLevel()<=4
		-- 检查怪兽是否可里侧除外且离场后能空出怪兽区格子
		and c:IsAbleToRemove(tp,POS_FACEDOWN) and (not chk or Duel.GetMZoneCount(tp,c)>0)
end
-- 过滤条件：里侧除外状态的5星以上「异解△」怪兽
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsLevelAbove(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动检查与设置操作信息：场上怪兽里侧除外与除外区怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上存在可里侧除外的4星以下「异解△」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp,true)
		-- 确认除外区存在可特殊召唤的里侧5星以上「异解△」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：将场上的1只怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：特殊召唤除外区的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：场上4星以下「异解△」怪兽里侧除外，特殊召唤里侧除外的5星以上「异解△」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足除外后有空格条件的「异解△」怪兽组
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil,tp,true)
	-- 若无满足空格条件的怪兽则获取所有满足条件的怪兽组
	if #g==0 then g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil,tp,false) end
	if #g==0 then return end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local dg=g:Select(tp,1,1,nil)
	-- 显示选中的要除外的怪兽
	Duel.HintSelection(dg)
	-- 将选中的怪兽里侧表示除外
	if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
		local tc=dg:GetFirst()
		if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"因「异解△福音」②被里侧除外"
		end
		-- 确认怪兽区有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从除外区选择1只里侧5星以上的「异解△」怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			if sg:GetCount()>0 then
				-- 将选中的怪兽表侧表示特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
