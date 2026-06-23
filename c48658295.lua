--ドラゴンメイド・ラティス
-- 效果：
-- 相同属性而等级不同的「半龙女仆」怪兽×2
-- 从自己的场上以及墓地各把1只上记的卡除外的场合才能从额外卡组特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1只4星以下的「半龙女仆」怪兽特殊召唤。
-- ②：自己·对方的准备阶段才能发动。自己的场上·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤规则、特殊召唤条件、两个效果
function s.initial_effect(c)
	-- 添加融合召唤手续，使用2个满足s.ffilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,2,false)
	c:EnableReviveLimit()
	-- 设置该卡的特殊召唤条件为必须从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 设置该卡的特殊召唤程序为场上的怪兽和墓地的怪兽各选1只除外才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 设置效果①：这张卡特殊召唤成功时发动，从卡组把1只4星以下的「半龙女仆」怪兽特殊召唤
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
	-- 设置效果②：自己·对方的准备阶段发动，自己的场上·除外状态的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤
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
-- 融合过滤函数，用于筛选满足融合条件的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	if not c:IsFusionSetCard(0x133) then return false end
	if not sg then return true end
	return not sg:IsExists(Card.IsLevel,1,c,c:GetLevel())
		and sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute())
end
-- 特殊召唤限制函数，确保该卡不能从额外卡组以外的位置特殊召唤
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 融合素材过滤函数，筛选「半龙女仆」怪兽且能除外作为代价
function s.fusfilter(c)
	return c:IsSetCard(0x133) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 融合选择函数，检查所选卡片是否满足等级不同、属性相同、包含场上和墓地的怪兽
function s.fselect(g)
	-- 融合选择函数返回值，表示满足等级不同、属性相同、包含场上和墓地的怪兽
	return g:GetClassCount(Card.GetLevel)==2 and aux.SameValueCheck(g,Card.GetFusionAttribute) and g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
end
-- 特殊召唤条件函数，检查是否有满足条件的融合素材
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上和墓地的「半龙女仆」怪兽组
	local fg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return fg:CheckSubGroup(s.fselect,2,2)
end
-- 特殊召唤目标函数，选择要除外的2只怪兽并设置为代价
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local cp=c:GetControler()
	-- 获取场上和墓地的「半龙女仆」怪兽组
	local g=Duel.GetMatchingGroup(s.fusfilter,cp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,cp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(cp,s.fselect,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数，将选中的怪兽作为代价除外
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	c:SetMaterial(sg)
	-- 将选中的怪兽除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 特殊召唤过滤函数，筛选4星以下的「半龙女仆」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(4)
end
-- 效果①的目标函数，检查是否满足特殊召唤条件
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场地位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤1只怪兽到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的操作函数，从卡组选择1只符合条件的怪兽特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的场地位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 融合素材过滤函数，筛选场上的怪兽作为融合素材
function s.filter0(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 融合素材过滤函数，筛选除外状态的怪兽作为融合素材
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤函数，筛选龙族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的目标函数，检查是否满足融合召唤条件
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取场上可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
		-- 获取除外状态的融合素材组
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_REMOVED,0,nil,e)
		mg1:Merge(mg2)
		-- 检查是否存在符合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在符合条件的融合怪兽（通过连锁）
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息为特殊召唤1只融合怪兽到场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息为将融合素材送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_REMOVED)
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的操作函数，选择融合怪兽并进行融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取场上可用的融合素材组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取除外状态的融合素材组（受王家长眠之谷影响）
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	mg1:Merge(mg2)
	-- 获取符合条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取符合条件的融合怪兽组（通过连锁）
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合怪兽或第二组融合怪兽
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce~=nil and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 确认对方玩家看到被翻开的卡
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 显示选中的卡作为对象
				Duel.HintSelection(cg)
			end
			-- 将融合素材送回卡组并洗牌
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 选择融合素材（通过连锁）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 用于筛选在墓地或除外状态的卡
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
