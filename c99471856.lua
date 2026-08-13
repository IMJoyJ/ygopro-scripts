--水晶機巧－トリスタロス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把效果发动时才能发动。从卡组把「水晶机巧-三位玉晶」以外的1只「水晶机巧」怪兽特殊召唤。那之后，用包含那只在内的自己场上的怪兽为素材进行1只机械族同调怪兽的同调召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只同调怪兽破坏，从卡组把2只「水晶机巧」怪兽特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册效果①（对方发动效果时从卡组特召1只『水晶机巧』怪兽并同调召唤1只机械族同调怪兽）和效果②（除外墓地自身，破坏自己1只同步怪兽并特召2只『水晶机巧』怪兽，附带回合同调限制）。
function s.initial_effect(c)
	-- ①：对方把效果发动时才能发动。从卡组把「水晶机巧-三位玉晶」以外的1只「水晶机巧」怪兽特殊召唤。那之后，用包含那只在内的自己场上的怪兽为素材进行1只机械族同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤并同调召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上1只同调怪兽破坏，从卡组把2只「水晶机巧」怪兽特殊召唤。这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏并特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（使用aux.bfgcost完成除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有当连锁中发动效果的玩家是对方（rp==1-tp）时，本效果才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 同调素材候选过滤：检查额外卡组中的机械族同调怪兽能否以tc（刚特殊召唤的调整）为素材进行同调召唤。
function s.cfilter(c,tc)
	return c:IsRace(RACE_MACHINE) and c:IsSynchroSummonable(tc)
end
-- ①效果从卡组检索的怪兽过滤：不是本卡（id）、属于「水晶机巧」系列（SetCard 0xea）、可以特殊召唤，并且额外卡组存在至少1只可以它作为调整进行同调召唤的机械族同调怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外卡组中存在至少1只满足s.cfilter（以c为调整可同调召唤的机械族同调怪兽）的卡。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- ①效果的发动条件判定：己方剩余特殊召唤次数至少2次、主要怪兽区有空位，且卡组存在满足s.spfilter的1只「水晶机巧」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查玩家tp是否还能进行至少2次特殊召唤（本效果流程为1次特殊召唤+1次同调召唤，共需2次特殊召唤次数）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上主要怪兽区是否有空位，以容纳随后特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足s.spfilter的「水晶机巧」怪兽（即可特召并支持后续同调的怪兽）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本效果涉及特殊召唤，可能从卡组或额外卡组特殊召唤1只怪兽，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果处理：从卡组选择1只符合条件的「水晶机巧」怪兽特殊召唤；成功后若它仍在场上，则从额外卡组选择1只机械族同调怪兽，以它为素材进行同调召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理开始时检查主要怪兽区是否有空位，若没有则中止效果，无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 显示选择卡片的提示信息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足s.spfilter的「水晶机巧」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽特殊召唤到自己场上；若特殊召唤成功（返回值>0），才继续后续同调处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 立即刷新场地状态，确保刚特殊召唤的怪兽被正确记录，供同调素材判定使用。
		Duel.AdjustAll()
		if not tc:IsLocation(LOCATION_MZONE) then return end
		-- 获取额外卡组中所有能以tc为素材进行同调召唤的机械族同调怪兽（满足s.cfilter的卡）。
		local etg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tc)
		if etg:GetCount()>0 then
			-- 显示选择卡片的提示信息，提示玩家选择要同调召唤的额外卡组怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=etg:Select(tp,1,1,nil)
			-- 中断当前效果链，使接下来的同调召唤与之前的特殊召唤不视为同时处理，避免误触发时点。
			Duel.BreakEffect()
			-- 执行同调召唤：以tc作为调整，将选择的额外卡组怪兽同调召唤上场。
			Duel.SynchroSummon(tp,sg:GetFirst(),tc)
		end
	end
end
-- ②效果选择破坏对象的过滤：自己场上的表侧表示同步怪兽，且破坏后自己场上仍有至少2个可用主要怪兽区（为后续特召2只做准备）。
function s.desfilter(c,tp)
	-- 判断对象为表侧表示同步怪兽，并且在其被破坏后自己的主要怪兽区空位数大于1。
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and Duel.GetMZoneCount(tp,c)>1
end
-- ②效果从卡组特殊召唤的怪兽过滤：属于「水晶机巧」系列（SetCard 0xea）、是怪兽且可以特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：自己场上存在可破坏的同步怪兽，当前没有青眼精灵龙（59822133）的效果限制（禁止双方同时特殊召唤2只以上怪兽），且卡组存在至少2只满足s.spfilter2的「水晶机巧」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足s.desfilter的同步怪兽集合g，作为破坏对象的候选。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return g:GetCount()>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查卡组中是否存在至少2只满足s.spfilter2的「水晶机巧」怪兽，以确保能够特殊召唤2只。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置操作信息：声明本效果会破坏1只怪兽，将候选组g登记为可能被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：声明本效果会从卡组特殊召唤2只怪兽（对象在处理时确定，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：选择自己场上1只同步怪兽破坏；若破坏成功且卡组仍有2只「水晶机巧」可特召、无青眼精灵龙限制、场上空位足够，则从卡组特殊召唤2只；最后给己方附加本回合不能从额外卡组特殊召唤非机械族怪兽的自肃。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择卡片的提示信息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1只满足s.desfilter的同步怪兽作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #g>0 then
		-- 手动显示被选择对象的动画，并记录这些卡被选为对象（广义的选对象信息）。
		Duel.HintSelection(g)
		-- 判断条件：破坏处理实际破坏了对象（返回值≠0），并且卡组中仍至少有2只满足s.spfilter2的「水晶机巧」怪兽可特殊召唤。
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.GetMatchingGroupCount(s.spfilter2,tp,LOCATION_DECK,0,nil,e,tp)>1
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查自己场上主要怪兽区空位数>1，确保可以特殊召唤2只怪兽。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
			-- 显示选择卡片的提示信息，提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选择2只满足s.spfilter2的「水晶机巧」怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,2,2,nil,e,tp)
			if sg:GetCount()>0 then
				-- 将选择的2只「水晶机巧」怪兽特殊召唤到自己场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个回合，自己不是机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册给玩家tp，持续到回合结束（RESET_PHASE+PHASE_END），限制该玩家的额外卡组特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃过滤条件：从额外卡组（LOCATION_EXTRA）特殊召唤怪兽时，若该怪兽不是机械族（RACE_MACHINE），则禁止特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end
