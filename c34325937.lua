--方界合神
-- 效果：
-- ①：从自己的手卡·场上把「方界」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：表侧表示的「方界」怪兽被战斗破坏的场合或者从场上离开的场合，把墓地的这张卡除外才能发动。从手卡·卡组把1只4星以下的「方界」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
function c34325937.initial_effect(c)
	-- ①：从自己的手卡·场上把「方界」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34325937,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c34325937.target)
	e1:SetOperation(c34325937.activate)
	c:RegisterEffect(e1)
	-- ②：表侧表示的「方界」怪兽被战斗破坏的场合或者从场上离开的场合，把墓地的这张卡除外才能发动。从手卡·卡组把1只4星以下的「方界」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34325937,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c34325937.spcon)
	-- 设置②效果的发动代价为把墓地中的这张卡除外：使用aux.bfgcost作为cost函数，在发动时检查此卡能否除外，并将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c34325937.sptg)
	e2:SetOperation(c34325937.spop)
	c:RegisterEffect(e2)
end
-- 定义融合素材过滤条件：排除对当前效果免疫的卡，确保选作融合素材的卡能被此效果正常处理。
function c34325937.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义可融合召唤的「方界」融合怪兽筛选条件：必须为融合怪兽、卡名含「方界」字段、满足连锁素材追加条件（若有）、能够以融合召唤方式特殊召唤，且能用当前素材组m作为融合素材。
function c34325937.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xe3) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果发动时的目标确认：chk==0时，先获取常规融合素材并检查额外卡组是否存在可融合召唤的「方界」融合怪兽；若没有则检查连锁素材效果，用其素材组再次检查；有则可发动。发动后设置特殊召唤的操作信息。
function c34325937.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp当前可用的融合素材组（包含手卡·场上的怪兽，以及受额外融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1张满足filter2条件的「方界」融合怪兽，素材组为常规融合素材mg1，用于判断能否发动。
		local res=Duel.IsExistingMatchingCard(c34325937.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家tp当前适用的连锁素材效果（若有），用于在常规素材无法融合时提供替代素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，使用其提供的素材组mg2和追加条件mf，再次检查额外卡组是否存在可融合召唤的「方界」融合怪兽。
				res=Duel.IsExistingMatchingCard(c34325937.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置当前连锁的操作信息：本次效果处理将进行1只怪兽的特殊召唤，目标位置为额外卡组，供相关卡牌检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：实际执行融合召唤。先准备常规素材组与连锁素材组，让玩家选择要融合召唤的额外怪兽；若选择常规素材，则选素材送墓并融合召唤；若选择连锁素材且玩家同意，则交由连锁素材效果处理；最后完成融合召唤手续。
function c34325937.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取常规融合素材组，并用filter1过滤掉对此效果免疫的卡，得到可用的素材集合mg1。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c34325937.filter1,nil,e)
	-- 用可用的常规素材mg1，从额外卡组中筛选出所有可融合召唤的「方界」融合怪兽，存入sg1。
	local sg1=Duel.GetMatchingGroup(c34325937.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家tp当前适用的连锁素材效果（若有），用于支持替代融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，用其素材组mg2和追加条件mf，从额外卡组中筛选出可融合召唤的「方界」融合怪兽，存入sg2。
		sg2=Duel.GetMatchingGroup(c34325937.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”，用于接下来的选择窗口。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的融合怪兽tc是否应使用常规素材流程：当tc在常规素材可融合的集合sg1中，且（无连锁素材集合sg2，或tc不在sg2中，或玩家选择不使用连锁素材）时，进入常规融合流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从常规融合素材mg1中选择融合怪兽tc所需的融合素材（不强制包含某张卡，chkf=tp表示以tp视角检查融合条件）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材mat1送去墓地，送墓原因标记为效果、作为融合素材、融合召唤（REASON_EFFECT+REASON_MATERIAL+REASON_FUSION）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 调用Duel.BreakEffect()中断当前效果链，使此后的融合召唤处理视为独立时点，避免错过融合召唤成功的时点。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式（SUMMON_TYPE_FUSION）表侧表示特殊召唤到玩家tp的场上（不检查召唤条件、不检查苏生限制）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 当使用连锁素材流程时，让玩家从连锁素材组mg2中选择融合怪兽tc所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义②效果的离场判定过滤条件：该卡此前必须是表侧表示、位于主要怪兽区且卡名含「方界」字段的怪兽。
function c34325937.cfilter(c)
	return c:IsPreviousSetCard(0xe3) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
end
-- ②效果触发条件：若本次离场事件中存在满足cfilter的卡，则条件成立，可以从墓地发动。
function c34325937.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34325937.cfilter,1,nil)
end
-- 定义可特殊召唤的「方界」怪兽筛选条件：卡名含「方界」、等级4以下、能够无视召唤条件特殊召唤（nocheck=true表示不检查召唤条件，nolimit=false仍检查苏生限制）。
function c34325937.spfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果发动时的目标检查：自己主要怪兽区有空位，且手卡·卡组中存在满足spfilter的「方界」怪兽，才能发动；满足后设置特殊召唤的操作信息。
function c34325937.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在至少1个空位，确保能进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1张满足spfilter条件的「方界」怪兽。
		and Duel.IsExistingMatchingCard(c34325937.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：本次效果处理将进行1只怪兽的特殊召唤，目标位置为手卡·卡组，供相关卡牌检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：若场上仍有空位，则从手卡·卡组选择1只符合条件的「方界」怪兽无视召唤条件特殊召唤，并给该怪兽赋予本回合内不会被战斗·效果破坏的效果。
function c34325937.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则结束效果处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”，用于接下来的选择窗口。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1只满足spfilter条件的「方界」怪兽（至少1张，最多1张）。
	local g=Duel.SelectMatchingCard(tp,c34325937.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选择怪兽且特殊召唤成功（返回值为非0），则继续为那只怪兽赋予抗性；否则不处理。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		g:GetFirst():RegisterEffect(e2)
	end
end
