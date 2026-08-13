--EMマンモスプラッシュ
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己场上有融合怪兽特殊召唤时才能发动。从自己的额外卡组把1只表侧表示的「异色眼」灵摆怪兽特殊召唤。
-- 【怪兽效果】
-- 「娱乐伙伴 洒水猛犸」的怪兽效果在决斗中只能使用1次。
-- ①：自己主要阶段才能发动。从自己场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c52963531.initial_effect(c)
	-- 为这张卡添加灵摆怪兽的基础属性，使其可以作为灵摆卡放置在灵摆区并进行灵摆召唤等处理。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己场上有融合怪兽特殊召唤时才能发动。从自己的额外卡组把1只表侧表示的「异色眼」灵摆怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetCondition(c52963531.spcon)
	e2:SetTarget(c52963531.sptg)
	e2:SetOperation(c52963531.spop)
	c:RegisterEffect(e2)
	-- 「娱乐伙伴 洒水猛犸」的怪兽效果在决斗中只能使用1次。①：自己主要阶段才能发动。从自己场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,52963531+EFFECT_COUNT_CODE_DUEL)
	e3:SetTarget(c52963531.target)
	e3:SetOperation(c52963531.operation)
	c:RegisterEffect(e3)
end
-- 判定一只怪兽是否为自己场上表侧表示的融合怪兽。
function c52963531.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 发动条件：本次特殊召唤成功的怪兽中，包含至少1只自己场上的表侧表示融合怪兽。
function c52963531.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52963531.cfilter,1,nil,tp)
end
-- 筛选额外卡组中表侧表示且属于「异色眼」灵摆怪兽、能够被特殊召唤并有可用额外怪兽区域的卡。
function c52963531.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)
		-- 确认该怪兽满足特殊召唤条件，并且有可用的额外卡组怪兽特殊召唤区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 灵摆效果的目标处理：确认存在可特殊召唤的「异色眼」灵摆怪兽后，登记本次特殊召唤的操作信息。
function c52963531.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查额外卡组是否存在至少1只符合条件的「异色眼」灵摆怪兽可供特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c52963531.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次灵摆效果将进行特殊召唤的操作信息，对象数量1，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 灵摆效果处理：玩家从额外卡组选择1只符合条件的「异色眼」灵摆怪兽，以表侧表示特殊召唤到自己场上。
function c52963531.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示信息，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组中选择1只满足「异色眼」灵摆条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c52963531.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选可作为融合素材的卡片：该卡在场上且不免疫此效果，能够被效果处理作为素材送去墓地。
function c52963531.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 筛选可作为融合召唤对象的龙族融合怪兽：位于额外卡组、种族为龙、满足融合召唤条件且可用给定素材进行融合召唤。
function c52963531.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合效果的目标处理：检查能否用普通素材或连锁素材进行龙族融合召唤，并登记特殊召唤操作信息。
function c52963531.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方可作为融合素材的卡组，并筛选出其中的场上卡片。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组中是否存在至少1只能够用当前场上素材融合召唤的龙族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c52963531.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（若存在），以便后续扩展可用融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若使用连锁素材，检查额外卡组中是否存在至少1只能够用连锁素材提供的素材融合召唤的龙族融合怪兽。
				res=Duel.IsExistingMatchingCard(c52963531.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次融合效果将进行特殊召唤（融合召唤）的操作信息，对象数量1，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合效果处理：获取可用素材并筛选可融合召唤的龙族融合怪兽；玩家选择一只后，若使用通常素材则选择素材送墓并融合召唤，若选择使用连锁素材则按连锁素材效果融合召唤；最后完成融合召唤的完整处理。
function c52963531.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取己方可用融合素材，并筛选出场上且不免疫此效果的卡作为候选素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c52963531.filter1,nil,e)
	-- 收集额外卡组中能够用上述普通素材融合召唤的龙族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c52963531.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家适用的连锁素材效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若有连锁素材，收集额外卡组中能够用连锁素材提供的素材融合召唤的龙族融合怪兽。
		sg2=Duel.GetMatchingGroup(c52963531.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示提示信息，让玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通素材路线：所选怪兽在普通素材可融合候选内，且（无连锁素材可用、不在连锁素材候选内，或玩家选择不使用连锁素材）时走普通融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中为所选融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将所选融合素材送去墓地（原因：效果+素材+融合）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与之后怪兽的融合召唤被视为不同时点处理。
			Duel.BreakEffect()
			-- 以融合召唤方式将所选龙族融合怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中为所选融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
