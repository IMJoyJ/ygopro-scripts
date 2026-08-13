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
	-- 注册一个自定义活动计数器（ID 4682617），监听“发动效果”的行为；当发动的是「魔界台本」魔法卡的效果时，该计数器加1（最多1次），用于后续条件判定本回合是否发动过「魔界台本」魔法卡。
	Duel.AddCustomActivityCounter(4682617,ACTIVITY_CHAIN,c4682617.chainfilter)
end
-- 计数器过滤函数：若本次发动的是「魔界台本」魔法卡的效果则返回 false（使计数器增加），否则返回 true（不增加），以此记录本回合是否发动过「魔界台本」魔法卡效果。
function c4682617.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x20ec))
end
-- 效果发动条件：通过自定义计数器确认本回合已经发动过「魔界台本」魔法卡的效果（计数大于0），否则不能发动本卡。
function c4682617.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自定义计数器的值大于0，即确认本回合发动过至少1次「魔界台本」魔法卡效果。
	return Duel.GetCustomActivityCount(4682617,tp,ACTIVITY_CHAIN)>0
end
-- 检索/筛选条件：要求是表侧表示、属于「魔界剧团」系列、且为灵摆怪兽，并能加入手卡；用于从额外卡组选择要加入手卡的卡。
function c4682617.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检索/筛选条件：要求手牌中的卡属于「魔界剧团」系列、为灵摆怪兽，且能够被当前效果特殊召唤；用于后续选择特殊召唤的卡。
function c4682617.spfilter(c,e,tp)
	return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选条件：要求是「魔界台本」魔法卡；用于计算墓地中「魔界台本」魔法卡的数量，决定可加入手卡及特殊召唤的数量上限。
function c4682617.ctfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x20ec)
end
-- 效果发动目标合法性判定：在发动时确认自己墓地至少存在1张「魔界台本」魔法卡，且自己的额外卡组存在至少1张表侧表示的「魔界剧团」灵摆怪兽，否则不能发动。
function c4682617.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张「魔界台本」魔法卡（ctfilter），作为可发动的前提条件之一。
	if chk==0 then return Duel.IsExistingMatchingCard(c4682617.ctfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己的额外卡组是否存在至少1张满足thfilter的表侧「魔界剧团」灵摆怪兽，作为可发动的前提条件之一。
		and Duel.IsExistingMatchingCard(c4682617.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置本次连锁的操作信息：本效果包含“从额外卡组将卡加入手卡”的处理，预计操作数量为1，对象玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	-- 设置本次连锁的操作信息：本效果包含“从手卡将怪兽特殊召唤”的处理，预计操作数量为1，对象玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：首先给己方附加“不能特殊召唤非「魔界剧团」灵摆怪兽”的自肃（持续到回合结束）；然后统计墓地「魔界台本」魔法卡数量，选择最多该数量的表侧「魔界剧团」灵摆怪兽从额外卡组加入手卡；若成功加入，再根据实际加入数量和场地/卡名限制选择手牌中的「魔界剧团」灵摆怪兽进行特殊召唤（同名卡最多1张），并处理青眼精灵龙等限制。
function c4682617.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 把最多有自己墓地的「魔界台本」魔法卡数量的表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组加入手卡。那之后，可以把最多有这个效果加入手卡的怪兽数量的「魔界剧团」灵摆怪兽从手卡特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不是「魔界剧团」灵摆怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c4682617.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将生成的自肃效果（不能特殊召唤非「魔界剧团」灵摆怪兽）注册到己方，效果持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
	end
	-- 统计自己墓地中「魔界台本」魔法卡的数量，作为可加入手卡的最大数量。
	local ct=Duel.GetMatchingGroupCount(c4682617.ctfilter,tp,LOCATION_GRAVE,0,nil)
	if ct<=0 then return end
	-- 弹出“请选择要加入手卡的卡”的提示信息，供玩家在选择额外卡组卡片时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的额外卡组中选择1~ct张满足条件的表侧「魔界剧团」灵摆怪兽加入手卡；ct为墓地「魔界台本」魔法卡数量。
	local hg=Duel.SelectMatchingCard(tp,c4682617.thfilter,tp,LOCATION_EXTRA,0,1,ct,nil)
	-- 若选中的卡组不为空，且成功将卡加入手卡（返回实际操作数不为0），才继续执行后续特殊召唤处理。
	if hg:GetCount()>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)~=0 then
		-- 统计本次效果实际加入手卡且由自己控制的怪兽数量，作为接下来可特殊召唤的最大数量。
		local sct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,tp)
		-- 获取手牌中所有可被特殊召唤的「魔界剧团」灵摆怪兽（满足spfilter），作为特殊召唤的候选集合。
		local sg=Duel.GetMatchingGroup(c4682617.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 计算本次最多可特殊召唤的数量：取可用主要怪兽区空格数与候选怪兽中不同卡名种类数的较小值，以此限制特殊召唤数量且同名卡最多1张。
		local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),sg:GetClassCount(Card.GetCode))
		-- 当实际加入手卡数量大于0、可特殊召唤上限大于0，且玩家确认选择“是”时，才执行特殊召唤处理。
		if sct>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(4682617,0)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤作为独立处理，避免错过时点（相当于分步处理）。
			Duel.BreakEffect()
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 弹出“请选择要特殊召唤的卡”的提示信息，供玩家在特殊召唤选择时显示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从候选组中选择1~min(ft,sct)张「魔界剧团」灵摆怪兽，且所选卡的卡名互不相同（满足同名卡最多1张的限制）。
			local g=sg:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,sct))
			-- 将选择好的「魔界剧团」灵摆怪兽以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 自肃过滤函数：如果怪兽不是「魔界剧团」灵摆怪兽则禁止特殊召唤，即本卡发动后只能特殊召唤「魔界剧团」灵摆怪兽。
function c4682617.splimit(e,c)
	return not (c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM))
end
