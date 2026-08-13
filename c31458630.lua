--幻奏協奏曲
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只天使族融合怪兽融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
-- ②：这张卡在墓地存在的状态，「幻奏」融合怪兽被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡回到卡组最下面。那之后，自己抽1张。
function c31458630.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己的手卡·场上的怪兽作为融合素材，把1只天使族融合怪兽融合召唤。那个时候，自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31458630)
	e1:SetTarget(c31458630.target)
	e1:SetOperation(c31458630.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，「幻奏」融合怪兽被送去自己墓地的场合才能发动（伤害步骤也能发动）。这张卡回到卡组最下面。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31458630,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31458631)
	e2:SetCondition(c31458630.drcon)
	e2:SetTarget(c31458630.drtg)
	e2:SetOperation(c31458630.drop)
	c:RegisterEffect(e2)
end
c31458630.fusion_effect=true
-- 过滤函数：判断卡c是否能作为融合素材且不免疫当前效果e，用于额外获取灵摆区域的融合素材。
function c31458630.filter0(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断卡c是否不免疫当前效果e，用于从常规融合素材中剔除受此效果影响的卡。
function c31458630.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判断额外卡组的怪兽c是否为天使族融合怪兽，且能够用给定素材组m（及额外条件f）进行融合召唤，并能被此效果以融合召唤方式特殊召唤。
function c31458630.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的合法性检查：确认额外卡组存在能用当前素材（含灵摆区素材）融合召唤的天使族融合怪兽；若存在则登记融合召唤的操作信息。
function c31458630.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp可用的常规融合素材组（手卡·场上的怪兽及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 将灵摆区域中可作为融合素材且不免疫此效果的怪兽加入素材组，对应“自己的灵摆区域存在的融合素材怪兽也能作为融合素材使用”。
		mg1:Merge(Duel.GetMatchingGroup(c31458630.filter0,tp,LOCATION_PZONE,0,nil,e))
		-- 检查额外卡组是否存在至少1只天使族融合怪兽，能用素材组mg1进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c31458630.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp受到的连锁素材效果（如『连锁素材』），以便后续考虑替代素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材组mg2及条件mf，再次检查是否存在可融合召唤的天使族融合怪兽。
				res=Duel.IsExistingMatchingCard(c31458630.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本效果将进行的特殊召唤（融合召唤）操作信息，目标为额外卡组的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤处理：从候选融合怪兽中选择1只，若使用常规素材则选择素材送墓后特殊召唤；若使用连锁素材则按连锁素材效果执行。
function c31458630.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得常规融合素材组，并剔除对此效果免疫的怪兽，得到实际可用的融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c31458630.filter1,nil,e)
	-- 将灵摆区域可作素材且不免疫此效果的怪兽并入素材组（与发动时检查一致）。
	mg1:Merge(Duel.GetMatchingGroup(c31458630.filter0,tp,LOCATION_PZONE,0,nil,e))
	-- 筛选出所有能用素材组mg1融合召唤的天使族融合怪兽，作为可供玩家选择的融合召唤对象。
	local sg1=Duel.GetMatchingGroup(c31458630.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家tp受到的连锁素材效果（若存在），用于扩展可选的融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2及条件mf，筛选出可融合召唤的天使族融合怪兽并加入候选。
		sg2=Duel.GetMatchingGroup(c31458630.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从候选融合怪兽中选择1只需要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否属于常规素材候选，且（不存在连锁素材候选或玩家选择不使用连锁素材）；是则按常规融合召唤流程处理，否则使用连锁素材效果处理。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规素材组mg1中选择融合怪兽tc所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材以效果、素材和融合召唤的理由送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与融合召唤成为先后两个独立时点，避免错过时点。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，让玩家从连锁素材组mg2中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断卡c是否为我方控制的「幻奏」系列的融合怪兽，用于②的诱发条件。
function c31458630.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and c:IsControler(tp)
end
-- ②的发动条件：本次送去墓地的怪兽中包含我方控制的「幻奏」融合怪兽，且不是这张魔法卡本身被送去墓地（因为此卡已在墓地）。
function c31458630.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c31458630.cfilter,1,nil,tp)
end
-- ②发动时的合法性检查：确认此卡能够回到卡组且玩家可以抽1张卡。
function c31458630.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 检查玩家tp是否可以进行1张抽卡（作为②发动条件之一）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and c:IsAbleToDeck() end
	-- 登记将这张卡送回卡组的操作信息，对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	-- 登记玩家tp抽1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：将这张卡送回持有者卡组最下面，然后自己抽1张卡。
function c31458630.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与此效果关联，并以效果原因成功将其送回持有者卡组最下面。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK) then
		-- 中断效果处理，使抽卡在回卡组后作为独立时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 玩家tp以效果原因抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
