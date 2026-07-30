--D－HERO デスドグマガイ
local s,id,o=GetID()
-- 定义并注册该卡的所有效果：特殊召唤条件、特殊召唤手续、特殊召唤成功伤害效果、对方发卡时快速融合效果。
function s.initial_effect(c)
	-- 注册卡片的「D‑HERO」系列字段，使其被卡片效果识别为D‑HERO怪兽。
	aux.AddSetNameMonsterList(c,0xc008)
	c:EnableReviveLimit()
	-- 此卡不能通常召唤。仅能通过除外自己墓地3只暗属性或战士族怪兽从手牌或墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 此卡可以通过除外自己墓地3只暗属性或战士族怪兽，从手牌或墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e2)
	-- 此卡特殊召唤成功的回合的下个准备阶段，给予对方玩家2000点伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- 对方卡或效果发动时（快速效果），可以将此卡作为素材进行融合召唤，使用的融合素材返回卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.fspcon)
	e4:SetTarget(s.fsptg)
	e4:SetOperation(s.fspop)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤cost的过滤条件：返回墓地中暗属性或战士族且可除外的怪兽。
function s.spfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToRemoveAsCost()
end
-- 检查自己墓地是否有3只可用于除外的暗属性或战士族怪兽，且自己的怪兽区有空格。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回是否满足特殊召唤的条件：怪兽区有空格且墓地有3只暗属性或战士族可除外的怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,3,c)
end
-- 特殊召唤cost选择阶段：让玩家从墓地选择3只要除外的暗属性或战士族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中符合条件的cost怪兽列表。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤：将玩家选择的3只怪兽除外，然后特殊召唤此卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3只怪兽以表侧表示除外，作为特殊召唤的cost。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查此卡是否通过自身效果特殊召唤（用于触发伤害效果）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 注册在准备阶段触发的伤害效果，准备在对方回合的准备阶段造成2000点伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 此卡特殊召唤成功的回合的准备阶段时，给予对方玩家2000点伤害；对方卡或效果发动时（快速效果），可以将此卡作为素材进行融合召唤，使用的融合素材返回卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(s.damop2)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	-- 在玩家tp的回合注册伤害效果，使其在准备阶段触发。
	Duel.RegisterEffect(e1,tp)
end
-- 在准备阶段触发伤害效果，提示卡号并给予对方玩家2000点伤害。
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示此卡的卡号提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 给予对方玩家2000点伤害。
	Duel.Damage(1-tp,2000,REASON_EFFECT)
end
-- 判断对方是否发动了卡或效果（对方是当前连锁的响应方），返回true表示满足快速效果发动条件。
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义融合素材过滤条件：怪兽牌且不受该效果影响且可以被送入Deck。
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 定义融合怪兽过滤条件：暗属性或战士族的融合怪兽，且可以在玩家tp以SUMMON_TYPE_FUSION特殊召唤并检查素材。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 快速效果的代价检测：检查是否存在符合条件的融合怪兽并设置操作信息（特召和送Deck）。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可用的融合素材（手牌·场上），过滤符合filter1的怪兽。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取玩家tp墓地的符合条件的怪兽作为融合素材。
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在符合条件的融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp的连锁素材（若有），用于额外的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材检查是否有符合条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息，指定从额外卡组特召。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置将素材送入Deck的操作信息，指定手牌、场上、墓地。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 执行融合召唤：选择融合怪兽和素材，将素材送Deck并特殊召唤融合怪兽。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家tp可用的融合素材（手牌·场上）并过滤。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取墓地素材并应用 Necro Valley 过滤（若对方场上有王家长眠之谷则不能使用）。
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取可用融合怪兽列表（使用mg1素材）。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材（若有），用于额外的融合素材选择。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材时的融合怪兽候选列表。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合素材或连锁素材：若选择的卡在普通组且不使用连锁素材或对方未选择连锁素材，则使用普通素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从mg1中选择融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 确认素材给对手查看。
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 显示被选为素材的怪兽给己方。
				Duel.HintSelection(gg)
			end
			-- 将使用的融合素材送入Deck并洗牌。
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前连锁，使后续效果不同时处理。
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽（表侧攻击表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义素材检查：返回场上里侧表示的怪兽或手牌中的怪兽。
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 定义素材检查：返回场上表侧表示的怪兽或墓地的怪兽。
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
