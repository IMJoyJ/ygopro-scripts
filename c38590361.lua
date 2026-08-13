--螺旋融合
-- 效果：
-- ①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果把「龙骑士 盖亚」特殊召唤的场合，那只怪兽攻击力上升2600，同1次的战斗阶段中最多2次可以向怪兽攻击。
function c38590361.initial_effect(c)
	-- 在卡c上登记卡名「龙骑士 盖亚」（66889139），使这张卡视为记载有该卡名，用于后续关联判断或检索支持。
	aux.AddCodeList(c,66889139)
	-- ①：从自己的手卡·场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果把「龙骑士 盖亚」特殊召唤的场合，那只怪兽攻击力上升2600，同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38590361.target)
	e1:SetOperation(c38590361.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：返回素材怪兽不免疫当前效果e，确保素材能够被本效果作为融合素材正常处理。
function c38590361.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 候选融合怪兽的过滤条件：必须是龙族融合怪兽，且能被效果e以融合召唤方式特殊召唤，并能用可用的素材组m构成合法的融合素材组合。
function c38590361.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动目标的检测：检查额外卡组是否存在可用当前融合素材（包括连锁素材）融合召唤的龙族融合怪兽，若存在则可发动；若可发动则设置将进行特殊召唤的操作信息。
function c38590361.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家tp可用的融合素材组（通常是手卡·场上满足条件的怪兽，以及受特殊效果影响的额外素材）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1张龙族融合怪兽，能作为这次融合召唤的候选，且能用素材组mg1满足其融合素材要求。
		local res=Duel.IsExistingMatchingCard(c38590361.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家tp受到的『连锁素材』类效果（若有），用于在后续判断中扩展可选择的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则用其提供的素材组mg2再次检查额外卡组中是否有可融合召唤的龙族融合怪兽，作为备选方案。
				res=Duel.IsExistingMatchingCard(c38590361.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置本连锁的操作信息：效果将把1只怪兽从额外卡组特殊召唤，类别为特殊召唤（融合召唤）；对象在效果处理时确定，因此目标暂未指定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤：根据玩家选择确定融合怪兽和素材（普通素材或连锁素材），将素材送入墓地后进行融合召唤；若召唤的是「龙骑士 盖亚」，则为其附加攻击力上升2600及额外攻击怪兽一次的效果。
function c38590361.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材组，并剔除当前效果e免疫的卡，保证素材可以被本效果送去墓地。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c38590361.filter1,nil,e)
	-- 根据普通融合素材mg1，从额外卡组选出所有可融合召唤的龙族融合怪兽候选组sg1。
	local sg1=Duel.GetMatchingGroup(c38590361.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果对象，用于支持使用非传统素材进行融合召唤的情况。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，则根据其提供的素材mg2再次搜索额外卡组中可融合召唤的龙族融合怪兽候选组sg2。
		sg2=Duel.GetMatchingGroup(c38590361.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示，让玩家从候选融合怪兽中选择1只要特殊召唤的怪物。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否使用普通素材融合：若所选怪兽在普通候选组中，且（没有连锁素材候选或所选怪兽不在连锁候选组中，或玩家选择不使用连锁素材），则走普通融合流程；否则走连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通素材组中选择符合所选融合怪兽融合条件的素材（普通融合）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以效果原因和融合素材原因送去墓地，作为融合召唤的代价。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使素材送墓与后续特殊召唤作为不同的时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材组中选择符合所选融合怪兽条件的素材（供连锁素材效果处理）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		if tc:IsFaceup() and tc:IsCode(66889139) then
			-- 这个效果把「龙骑士 盖亚」特殊召唤的场合，那只怪兽攻击力上升2600。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(38590361,0))  --"「螺旋融合」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 同1次的战斗阶段中最多2次可以向怪兽攻击。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(1)
			tc:RegisterEffect(e2,true)
		end
	end
end
