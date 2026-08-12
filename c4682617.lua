--魔界劇団のカーテンコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「魔界台本」魔法卡的效果发动的回合才能发动。把最多有自己墓地的「魔界台本」魔法卡数量的表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组加入手卡。那之后，可以把最多有这个效果加入手卡的怪兽数量的「魔界剧团」灵摆怪兽从手卡特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
function c4682617.initial_effect(c)
	-- ①：「魔界台本」魔法卡的效果发动的回合才能发动。把最多有自己墓地的「魔界台本」魔法卡数量的表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组加入手卡。那之后，可以把最多有这个效果加入手卡的怪兽数量的「魔界剧团」灵摆怪兽从手卡特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4682617+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c4682617.condition)
	e1:SetTarget(c4682617.target)
	e1:SetOperation(c4682617.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中发动的魔法卡数量，排除「魔界台本」魔法卡的效果发动次数。
	Duel.AddCustomActivityCounter(4682617,ACTIVITY_CHAIN,c4682617.chainfilter)
end
-- 过滤函数：如果发动的是魔法卡且属于「魔界台本」系列，则不计入计数器。
function c4682617.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x20ec))
end
-- 条件函数：判断是否在「魔界台本」魔法卡的效果发动的回合中使用此卡。
function c4682617.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家在该回合中是否有发动过魔法卡（排除「魔界台本」），若有则满足发动条件。
	return Duel.GetCustomActivityCount(4682617,tp,ACTIVITY_CHAIN)>0
end
-- 检索过滤函数：用于筛选自己场上表侧表示的「魔界剧团」灵摆怪兽。
function c4682617.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 特殊召唤过滤函数：用于筛选可以被特殊召唤的「魔界剧团」灵摆怪兽。
function c4682617.spfilter(c,e,tp)
	return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 墓地过滤函数：用于筛选自己墓地中的「魔界台本」魔法卡。
function c4682617.ctfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec)
end
-- 目标设置函数：检查是否满足发动条件，即自己墓地有「魔界台本」魔法卡，并且额外卡组有符合条件的灵摆怪兽。
function c4682617.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否有至少一张「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4682617.ctfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己额外卡组是否有至少一张符合条件的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c4682617.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：指定效果处理时会将额外卡组中的灵摆怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：指定效果处理时会将手牌中的灵摆怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动函数：创建并注册一个禁止自己在本回合特殊召唤非「魔界剧团」灵摆怪兽的效果。
function c4682617.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：「魔界台本」魔法卡的效果发动的回合才能发动。把最多有自己墓地的「魔界台本」魔法卡数量的表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组加入手卡。那之后，可以把最多有这个效果加入手卡的怪兽数量的「魔界剧团」灵摆怪兽从手卡特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c4682617.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将创建的效果注册到场上，使该效果生效。
		Duel.RegisterEffect(e1,tp)
	end
	-- 统计自己墓地中的「魔界台本」魔法卡数量，作为后续操作的依据。
	local ct=Duel.GetMatchingGroupCount(c4682617.ctfilter,tp,LOCATION_GRAVE,0,nil)
	if ct<=0 then return end
	-- 提示玩家选择要加入手牌的灵摆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择最多与墓地「魔界台本」魔法卡数量相同的灵摆怪兽加入手牌。
	local hg=Duel.SelectMatchingCard(tp,c4682617.thfilter,tp,LOCATION_EXTRA,0,1,ct,nil)
	-- 如果成功将灵摆怪兽加入手牌，则继续处理后续特殊召唤逻辑。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)~=0 then
		-- 统计实际被送入手牌的灵摆怪兽数量。
		local sct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,tp)
		-- 获取自己手牌中符合条件的「魔界剧团」灵摆怪兽组。
		local sg=Duel.GetMatchingGroup(c4682617.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 计算最多可以特殊召唤的灵摆怪兽数量，考虑场地空位和卡名唯一性限制。
		local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),sg:GetClassCount(Card.GetCode))
		-- 询问玩家是否要将灵摆怪兽从手牌特殊召唤。
		if sct>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(4682617,0)) then  --"是否特殊召唤？"
			-- 中断当前效果处理流程，确保后续操作按顺序执行。
			Duel.BreakEffect()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 提示玩家选择要特殊召唤的灵摆怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从符合条件的灵摆怪兽中选择满足卡名唯一性要求的组进行特殊召唤。
			local g=sg:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,sct))
			-- 将选中的灵摆怪兽以特殊召唤方式加入场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 限制效果函数：禁止自己在本回合特殊召唤非「魔界剧团」灵摆怪兽。
function c4682617.splimit(e,c)
	return not (c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM))
end
