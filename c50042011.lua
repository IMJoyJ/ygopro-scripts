--メメント・スリーピィ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己怪兽被效果破坏的自己·对方回合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「莫忘」融合怪兽融合召唤。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把「莫忘催眠羊」以外的1张「莫忘」卡送去墓地。
local s,id,o=GetID()
-- 初始化并注册本卡全部效果：①从手卡特殊召唤（含全局破坏检测）、②召唤·特殊召唤时的融合召唤、③被破坏时从卡组将「莫忘」卡送去墓地。
function s.initial_effect(c)
	-- ①：自己怪兽被效果破坏的自己·对方回合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- ①：自己怪兽被效果破坏的自己·对方回合才能发动。这张卡从手卡特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「莫忘」融合怪兽融合召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.checkop)
		-- 将全局检测效果ge1注册到全场（以玩家0为持有者），持续监听场上怪兽被破坏的事件，用于记录“自己怪兽被效果破坏”的发生，为①效果的发动提供条件依据。
		Duel.RegisterEffect(ge1,0)
	end
	-- ②：这张卡召唤·特殊召唤的场合才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「莫忘」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从卡组把「莫忘催眠羊」以外的1张「莫忘」卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"卡组送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
s.fusion_effect=true
-- 过滤函数：判断被破坏的怪兽是否属于玩家tp控制过的怪兽，且不是从魔陷区被破坏，并且原本是怪兽（之前在怪兽区或原本种类为怪兽），同时破坏原因为效果破坏。用于识别“自己怪兽被效果破坏”的情况。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and not c:IsPreviousLocation(LOCATION_SZONE)
	and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
	and c:IsReason(REASON_EFFECT)
end
-- 全局破坏事件的处理函数：遍历双方玩家，若存在符合s.cfilter条件的怪兽（即某一方有怪兽被效果破坏），则为该玩家注册对应标记，表示该玩家本回合已有怪兽被效果破坏，从而允许①效果的发动。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(s.cfilter,1,nil,p) then
			-- 为玩家p注册id标记，持续到回合结束，计数1次，用于记录该玩家本回合已有怪兽被效果破坏这一事实。
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- ①效果的发动条件：检测当前玩家tp是否拥有id标记（即本回合自己怪兽是否被效果破坏过），有则满足发动条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回tp玩家的id标记数量是否大于0，即是否已经满足“自己怪兽被效果破坏”的发动前提。
	return Duel.GetFlagEffect(tp,id)>0
end
-- ①效果发动时的目标检查：在chk==0阶段确认自己主要怪兽区有空位，并且这张卡自身能够被特殊召唤，二者同时满足才能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查中，确认tp的主要怪兽区存在至少1个可用空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息：本效果包含特殊召唤，对象为这张卡自身，数量为1，用于系统检测相关效果（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理函数：取得效果持有者（这张卡），确认它仍与效果关联后，将其表侧表示特殊召唤到持有者场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到tp的场上，不检查召唤条件、不检查苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：筛选融合素材，排除不受当前效果影响的卡，得到可用于本次融合召唤的有效素材。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：额外卡组中的融合怪兽候选条件，要求是融合怪兽、属于「莫忘」字段、满足追加素材条件f、能以融合召唤方式特殊召唤，并且能用给定素材组m进行融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1a1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果发动时的目标检查：先获取常规融合素材并检查额外卡组是否存在可融合召唤的「莫忘」融合怪兽；若没有且存在连锁素材效果，则再用连锁素材提供的素材组检查；满足任一条件即可发动，发动后设置操作信息为从额外卡组特殊召唤1只怪兽。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取tp当前可用的融合素材组，包括手卡·场上的怪兽以及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只满足s.filter2条件的「莫忘」融合怪兽，且能够使用常规素材组mg1进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取tp受到的连锁素材效果（如其他卡提供的融合素材替代效果），若存在则用于追加可用素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在常规素材无法融合召唤时，使用连锁素材提供的素材组mg2和追加条件mf，再次检查额外卡组是否存在可融合召唤的「莫忘」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽；因为具体融合怪兽在处理时才确定，所以目标卡设为nil，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理函数：分别使用常规素材和连锁素材生成可选融合怪兽列表；让玩家选择要融合召唤的怪兽；若选择的是常规素材可召唤的怪兽，则选择素材并送入墓地后以融合召唤方式特殊召唤；若选择的是需要连锁素材的怪兽，则按连锁素材流程处理；最后完成融合怪兽的融合手续。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取常规融合素材组，并过滤掉不受当前效果影响的卡，得到本次融合召唤可用的有效素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 使用有效常规素材组mg1，从额外卡组筛选出所有可融合召唤的「莫忘」融合怪兽，作为候选列表sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，用于扩展融合素材来源，处理需要特殊素材的融合召唤。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2和追加条件mf，从额外卡组筛选出所有可融合召唤的「莫忘」融合怪兽，作为额外候选列表sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给tp发送选择提示消息，要求从候选融合怪兽中选择要特殊召唤的卡，并将提示内容写入选择缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽tc是否在常规素材候选列表sg1中，并且（不存在连锁素材候选列表sg2，或tc不在sg2中，或玩家选择不使用连锁素材），若成立则执行常规融合召唤流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让tp从常规素材组mg1中选择用于融合召唤tc的一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以“效果+素材+融合”的理由送去墓地，作为融合素材使用。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤被视为不同时点的处理，避免错过融合怪兽召唤成功时的选发时点。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到tp的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材时，让tp从连锁素材组mg2中选择用于融合召唤tc的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ③效果的发动条件：判断这张卡被破坏的原因是否包含战斗破坏或效果破坏（r中含有REASON_EFFECT或REASON_BATTLE），满足则可发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 筛选从卡组送去墓地的卡：卡名不是「莫忘催眠羊」、属于「莫忘」字段、且当前能够被送去墓地。
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1a1) and c:IsAbleToGrave()
end
-- ③效果发动时的目标检查：在chk==0阶段检查卡组是否存在至少1张符合条件的「莫忘」卡；合法后设置操作信息为从卡组将1张卡送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查时，确认tp的卡组中存在至少1张满足s.tgfilter的「莫忘」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡送去墓地；因为具体卡牌在处理时选择，所以目标卡设为nil，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理函数：弹出选择提示，让tp从卡组选择1张符合条件的「莫忘」卡，并将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给tp发送选择提示消息，要求选择要送去墓地的卡，并将提示内容写入选择缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让tp从卡组选择恰好1张满足s.tgfilter条件的「莫忘」卡作为处理对象。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果理由送去墓地，完成③效果的送墓处理。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
