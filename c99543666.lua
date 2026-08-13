--烙印劇城デスピア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只8星以上的融合怪兽融合召唤。
-- ②：融合怪兽以外的自己场上的表侧表示的天使族怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1只8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。
function c99543666.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只8星以上的融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99543666,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,99543666)
	e2:SetTarget(c99543666.fustg)
	e2:SetOperation(c99543666.fusop)
	c:RegisterEffect(e2)
	-- ②：融合怪兽以外的自己场上的表侧表示的天使族怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1只8星以上的融合怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99543666,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,99543667)
	e3:SetCondition(c99543666.spcon)
	e3:SetTarget(c99543666.sptg)
	e3:SetOperation(c99543666.spop)
	c:RegisterEffect(e3)
end
-- 过滤融合素材：排除不受当前效果影响（免疫者）的卡，使其不能作为融合素材。
function c99543666.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检查额外卡组怪兽是否可作为融合召唤对象：需为8星以上融合怪兽，满足追加素材条件，能以融合召唤方式特殊召唤，并可使用给定素材组进行融合召唤。
function c99543666.filter2(c,e,tp,m,f,chkf)
	return c:IsLevelAbove(8) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果的发动条件：确认额外卡组存在能用当前融合素材（或连锁素材）融合召唤的8星以上融合怪兽；发动时登记从额外卡组特殊召唤1只怪兽的操作信息。
function c99543666.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家的融合素材组，包括手卡·场上的怪兽及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只符合条件的融合怪兽，且能用mg1作为素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c99543666.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若有），用于替代通常融合素材进行融合召唤。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg2再次检查额外卡组是否存在符合条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(c99543666.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记效果处理时将把1只额外卡组的怪兽特殊召唤的操作信息（供其他卡响应）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行①效果的融合召唤：合并可选的融合怪兽列表，让玩家选择要融合召唤的怪兽，再选择融合素材并送墓，将怪兽以融合召唤方式特殊召唤；若使用连锁素材则按相应效果处理，最后完成融合召唤程序。
function c99543666.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前玩家的融合素材组，并剔除不受本效果影响的卡，确保素材可用。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c99543666.filter1,nil,e)
	-- 从额外卡组中获取所有能用mg1作为素材进行融合召唤且满足条件的融合怪兽候选组。
	local sg1=Duel.GetMatchingGroup(c99543666.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（若有），用于在效果处理时决定是否使用代替素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2，获取额外卡组中符合条件的融合怪兽候选组。
		sg2=Duel.GetMatchingGroup(c99543666.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡片（发送“请选择要特殊召唤的卡”的选择消息）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否执行普通融合召唤流程：所选怪兽在通常素材候选组中，且（无连锁素材候选或该怪兽不在连锁素材候选组中，或玩家选择不使用连锁素材）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常融合素材组mg1中选择融合召唤该怪兽所需的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，送入原因是效果处理、融合素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与特殊召唤分属不同时点，避免相关卡片错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式（SUMMON_TYPE_FUSION）表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材效果时，让玩家从连锁素材组mg2中选择该融合怪兽的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的离场怪兽条件：之前为表侧表示、原本控制者为自己、种族为天使族且不是融合怪兽，并且离场原因是战斗破坏或对方的效果。
function c99543666.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:GetPreviousRaceOnField()&RACE_FAIRY~=0 and c:GetPreviousTypeOnField()&TYPE_FUSION==0
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- ②效果的发动条件：离场怪兽集合中存在满足条件的表侧表示非融合天使族怪兽。
function c99543666.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99543666.cfilter,1,nil,tp,rp)
end
-- ②效果的对象条件：墓地中8星以上的融合怪兽，且能够被特殊召唤。
function c99543666.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与取对象：确认自己场上有可用怪兽区且墓地存在可特殊召唤的8星以上融合怪兽，然后将其选为效果对象。
function c99543666.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99543666.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上有可用的怪兽区域（至少1个空格）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：墓地存在至少1只可成为对象的8星以上融合怪兽。
		and Duel.IsExistingTarget(c99543666.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片（发送“请选择要特殊召唤的卡”的选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从墓地选择1只符合条件的融合怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,c99543666.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记效果处理时将所选对象卡特殊召唤的操作信息，并指定该对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果：取得对象融合怪兽，若仍合法则将其特殊召唤到自己场上。
function c99543666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选择的融合怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象融合怪兽以表侧攻击表示特殊召唤到自己场上（无特殊召唤方式限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
