--ドラゴンメイド・ラティス
-- 效果：
-- 相同属性而等级不同的「半龙女仆」怪兽×2
-- 从自己的场上以及墓地各把1只上记的卡除外的场合才能从额外卡组特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只4星以下的「半龙女仆」怪兽特殊召唤。
-- ②：自己·对方的准备阶段才能发动。自己的场上·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册融合素材召唤手续、从额外卡组除外素材的特殊召唤规则，以及①特殊召唤时从卡组特召和②准备阶段融合召唤两个诱发效果，并通过e3/e4的CountLimit实现“这个卡名的①②的效果1回合各能使用1次。”
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：使用2只满足s.ffilter条件的「半龙女仆」怪兽作为融合素材，对应效果原文“相同属性而等级不同的「半龙女仆」怪兽×2”。
	aux.AddFusionProcFunRep(c,s.ffilter,2,false)
	c:EnableReviveLimit()
	-- 对应效果原文“才能从额外卡组特殊召唤。”这条代码设置特殊召唤条件限制：该卡只能在位于额外卡组时被特殊召唤，防止从其他区域被特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 对应效果原文“从自己的场上以及墓地各把1只上记的卡除外的场合才能从额外卡组特殊召唤。”这条代码设置特殊召唤手续：通过从自己场上和墓地各除外1只符合条件的「半龙女仆」怪兽来从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文“①：这张卡特殊召唤的场合才能发动。从卡组把1只4星以下的「半龙女仆」怪兽特殊召唤。”该效果为这张卡特殊召唤成功时诱发的选发效果，1回合1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)
	-- 对应效果原文“②：自己·对方的准备阶段才能发动。自己的场上·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。”该效果为双方准备阶段可发动的诱发选发效果，1回合1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,id+o)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.fsptg)
	e4:SetOperation(s.fspop)
	c:RegisterEffect(e4)
end
-- 融合素材选择函数：判断候选怪兽c是否为「半龙女仆」字段怪兽；在没有已选素材时直接通过；有已选素材时，要求c的等级与已选素材中所有怪兽等级均不同，并且至少与其中1张属性相同，从而保证整体素材满足“相同属性而等级不同”。
function s.ffilter(c,fc,sub,mg,sg)
	if not c:IsFusionSetCard(0x133) then return false end
	if not sg then return true end
	return not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())
		and sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
end
-- 特殊召唤条件限制函数：仅当这张卡位于额外卡组时才允许被特殊召唤，即只能从额外卡组特殊召唤。
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 可除外素材过滤函数：选择自己场上或墓地中卡名含有「半龙女仆」的怪兽，且该卡能够作为代价除外。
function s.fusfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 选择2张除外素材的综合判定：2张卡的等级种类数恰好为2（即等级不同）、融合属性全部相同，并且其中至少1张来自场上、至少1张来自墓地。
function s.fselect(g)
	-- 判定条件细分：等级种类数为2、融合属性存在共同属性交集（属性相同），且素材组中同时包含场上和墓地的卡。
	return g:GetClassCount(Card.GetLevel)==2 and aux.SameValueCheck(g,Card.GetFusionAttribute) and g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 特殊召唤手续的发动条件：当c为nil时规则询问返回true；否则检查自己场上和墓地中是否存在2张满足s.fselect条件的素材，以决定能否从额外卡组进行除外素材特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上和墓地中所有可作为除外素材的「半龙女仆」怪兽，作为特殊召唤手续的候选素材组。
	local fg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return fg:CheckSubGroup(s.fselect,2,2)
end
-- 特殊召唤手续的目标选择：从候选素材中选出2张满足s.fselect条件的卡（场上和墓地各1只、等级不同、属性相同），将选择结果KeepAlive并存入效果标签，供后续除外使用。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	-- 获取自己场上和墓地中可作为除外素材的「半龙女仆」怪兽候选组。
	local g=Duel.GetMatchingGroup(s.fusfilter,cp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 向玩家显示“请选择要除外的卡”的选择提示，要求玩家选择要作为召唤代价除外的素材。
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(cp,s.fselect,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：取出之前保存的素材组，将其设置为该卡的融合素材，并把这些素材表侧表示除外，作为从额外卡组特殊召唤的代价。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选定的2张素材以表侧表示除外（REASON_COST），完成特殊召唤所需的代价操作。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①效果可特殊召唤的怪兽过滤：卡名含有「半龙女仆」字段、等级4以下且能够被玩家tp特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end
-- ①效果的发动条件（target）：己方怪兽区有空位，且卡组中存在至少1只满足s.spfilter条件的4星以下「半龙女仆」怪兽可以特殊召唤。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：己方主要怪兽区可用区域数量大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之二：卡组中存在至少1只满足s.spfilter的4星以下「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果属于特殊召唤分类，预期从卡组特殊召唤1只怪兽，用于连锁和效果发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示“己方发动了①效果”的提示，显示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的处理：若己方怪兽区仍有空位，则从卡组选择1只满足条件的4星以下「半龙女仆」怪兽，表侧表示特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家从卡组选择要特殊召唤的半龙女仆怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足s.spfilter条件的4星以下「半龙女仆」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果可用作融合素材的场上怪兽过滤：位于主要怪兽区、是怪兽、可作为融合素材、可返回卡组且不受该效果影响。
function s.filter0(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- ②效果可用作融合素材的除外区怪兽过滤：表侧表示除外、是怪兽、可作为融合素材、可返回卡组且不受该效果影响。
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- ②效果可融合召唤的目标过滤：融合怪兽、龙族、满足额外提供的素材条件（如有）、可以以融合召唤方式特殊召唤，并且能用给定素材组m进行融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动条件：准备阶段检查己方可用融合素材（场上和除外区的怪兽）能否融合召唤龙族融合怪兽；若通常素材不行，再检查连锁素材效果是否提供额外素材。满足后设置操作信息并提示对方。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方通常可用的融合素材（包含手卡、场上及受效果影响的额外素材），并过滤出满足s.filter0的场上怪兽。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
		-- 获取己方除外区中满足s.filter1的表侧表示怪兽，作为额外的融合素材候选。
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_REMOVED,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在至少1只龙族融合怪兽，可以使用mg1素材组进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材类效果（EFFECT_EXTRA_FUSION_MATERIAL），用于扩展融合召唤的素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 如果通常素材无法融合，进一步检查使用连锁素材效果提供的素材组mg3时，是否存在可融合召唤的龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果包含特殊召唤分类，预期从额外卡组特殊召唤1只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次效果包含回卡组分类，预期从场上或除外区返回卡组素材。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_REMOVED)
	-- 向对方玩家提示己方发动了②效果（融合召唤）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的处理：综合己方场上与除外区的素材，选择要融合召唤的龙族融合怪兽和对应素材，将素材返回持有者卡组并洗切后进行融合召唤；同时处理连锁素材、里侧素材确认以及墓地/除外区素材的选中提示。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理阶段获取己方当前可用的融合素材，并过滤出满足s.filter0的场上怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取己方场上和除外区中不受王家长眠之谷影响的、满足s.filter1的怪兽，作为可回卡组的融合素材候选。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	mg1:Merge(mg2)
	-- 检索额外卡组中所有能够使用通常素材组mg1融合召唤的龙族融合怪兽，作为可选的融合召唤目标。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果，用于判断是否可以采用额外素材组进行融合召唤。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则获取使用连锁素材组mg3能够融合召唤的龙族融合怪兽，并追加到可选目标组中。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择要融合召唤的龙族融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽使用通常素材还是连锁素材：若该怪兽属于通常素材可融合目标且未选择使用连锁素材，则执行通常融合流程；否则执行连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce~=nil and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 使用通常素材时，让玩家从素材组mg1中选择该融合怪兽所需的融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 若融合素材中存在里侧表示的卡，向对方玩家确认这些里侧卡，以公开融合素材信息。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 为位于墓地或除外区的素材显示被选中的动画提示，并记录这些卡被选为融合素材。
				Duel.HintSelection(cg)
			end
			-- 将选定的融合素材返回持有者卡组并洗切，作为融合召唤的素材处理（回卡组）。
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使随后的融合召唤不与此前的回卡组处理视为同时进行，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式（SUMMON_TYPE_FUSION）表侧表示特殊召唤到己方场上，完成融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 使用连锁素材效果时，让玩家从连锁素材组mg3中选择融合召唤所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义需要显示选中动画的素材过滤条件：素材位于墓地或除外区。
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
