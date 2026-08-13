--ウィッチクラフト・コンフュージョン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·场上把融合怪兽卡决定的包含「魔女术」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c35098357.initial_effect(c)
	-- ①：包含「魔女术」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35098357)
	e1:SetTarget(c35098357.target)
	e1:SetOperation(c35098357.activate)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段，这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35098357)
	e2:SetCondition(c35098357.thcon)
	e2:SetTarget(c35098357.thtg)
	e2:SetOperation(c35098357.thop)
	c:RegisterEffect(e2)
end
-- 判断怪兽是否不免疫此效果，只有不免疫的怪兽才可作为本次融合召唤的素材。
function c35098357.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中可进行融合召唤的融合怪兽：必须是融合怪兽，满足额外素材条件（如有），能够以此效果融合召唤，且能用给定素材组凑齐融合素材。
function c35098357.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 追加的素材合法性检查：融合素材组中必须存在至少1张「魔女术」字段的怪兽，以满足此卡融合素材包含「魔女术」怪兽的限制。
function c35098357.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x128)
end
-- 效果①的发动条件检查：确认额外卡组中是否存在能用包含「魔女术」怪兽的素材融合召唤的融合怪兽，若有连锁素材也一并检查；满足条件后设置特殊召唤的操作信息。
function c35098357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材组，包含手卡·场上的怪兽以及受额外融合素材效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置额外素材检查条件：要求融合素材组合中必须包含「魔女术」怪兽。
		aux.FCheckAdditional=c35098357.fcheck
		-- 检查额外卡组中是否存在至少1只融合怪兽，能够用当前素材组mg1并满足「魔女术」素材条件完成融合召唤。
		local res=Duel.IsExistingMatchingCard(c35098357.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除额外素材检查条件，避免影响后续其他判定。
		aux.FCheckAdditional=nil
		if not res then
			-- 获取当前玩家是否具有可代替融合素材的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，检查额外卡组中是否存在融合怪兽能够使用该连锁素材组mg2并满足融合召唤条件。
				res=Duel.IsExistingMatchingCard(c35098357.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：效果处理时将从额外卡组特殊召唤1只怪兽，供相关卡（如暴走魔法阵）检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的融合召唤处理：选择1只融合怪兽，选择包含「魔女术」怪兽的融合素材并送入墓地，将其融合召唤；若有连锁素材并选择使用时则按对应连锁素材处理。
function c35098357.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取普通融合素材组，并过滤掉免疫此效果的怪兽，得到实际可用的素材组mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c35098357.filter1,nil,e)
	-- 设置额外素材检查条件：要求融合素材组合中必须包含「魔女术」怪兽。
	aux.FCheckAdditional=c35098357.fcheck
	-- 获取额外卡组中所有能以素材组mg1进行融合召唤且满足「魔女术」素材限制的融合怪兽集合sg1。
	local sg1=Duel.GetMatchingGroup(c35098357.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除额外素材检查条件。
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家是否具有连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，获取额外卡组中所有能以连锁素材组mg2进行融合召唤的融合怪兽集合sg2。
		sg2=Duel.GetMatchingGroup(c35098357.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 显示选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用普通素材流程：当所选融合怪兽可用普通素材融合，且不存在可用的连锁素材、或该怪兽不在连锁素材可用范围内、或玩家选择不使用连锁素材时，执行普通融合处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置额外素材检查条件：要求融合素材组合中必须包含「魔女术」怪兽。
			aux.FCheckAdditional=c35098357.fcheck
			-- 让玩家从普通素材组mg1中选择符合该融合怪兽要求且包含「魔女术」怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除额外素材检查条件。
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送入墓地，送墓原因为效果、作为素材和用于融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续融合召唤作为独立动作处理，避免错失时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择使用连锁素材时，让玩家从连锁素材组mg2中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 筛选自己场上表侧表示且属于「魔女术」字段的怪兽，用于②效果的发动条件。
function c35098357.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果②发动条件：当前回合为自己的结束阶段，且自己场上有表侧表示「魔女术」怪兽存在。
function c35098357.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己，即处于自己的结束阶段。
	return Duel.GetTurnPlayer()==tp
		-- 确认自己场上有至少1只表侧表示的「魔女术」怪兽。
		and Duel.IsExistingMatchingCard(c35098357.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动目标判断：确认此卡在墓地存在且能够加入手卡，并设置将自身加入手卡的操作信息。
function c35098357.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将这张卡加入持有者手卡，回手牌对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理：若这张卡仍与此效果相关，则将其从墓地加入持有者手卡。
function c35098357.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡送去持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
