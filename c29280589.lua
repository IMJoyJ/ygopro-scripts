--エッジインプ・サイズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段，把手卡的这张卡给对方观看才能发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的包含手卡的这张卡的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己场上的「魔玩具」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c29280589.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方主要阶段，把手卡的这张卡给对方观看才能发动。从自己的手卡·场上把「魔玩具」融合怪兽卡决定的包含手卡的这张卡的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29280589,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,29280589)
	e1:SetCondition(c29280589.condition)
	e1:SetCost(c29280589.cost)
	e1:SetTarget(c29280589.target)
	e1:SetOperation(c29280589.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己场上的「魔玩具」融合怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29280590)
	e2:SetTarget(c29280589.reptg)
	e2:SetValue(c29280589.repval)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：必须是对方的主要阶段1或主要阶段2，且当前回合玩家为对方，才能发动。
function c29280589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段为主要阶段1或主要阶段2，且当前回合玩家是发动者的对手，满足①效果的‘对方主要阶段’发动时机。
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and Duel.GetTurnPlayer()==1-tp
end
-- ①效果的发动代价：需将手卡的这张卡展示给对方观看，因此要求此卡当前为非公开状态；若已公开则不能作为展示代价发动。
function c29280589.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤融合素材：排除对当前效果免疫的卡，即可用的素材必须不对此效果免疫。
function c29280589.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可融合召唤的融合怪兽：必须是「魔玩具」融合怪兽，能以此效果以融合召唤方式特殊召唤，并且可用素材组m（包含gc这张手牌）作为融合素材。
function c29280589.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ①效果的发动检查：先从额外卡组搜索是否存在可用通常素材融合召唤的「魔玩具」融合怪兽；若无，再检查连锁素材效果。无论哪种素材，都必须满足包含手卡的这张卡。满足则效果可发动，并登记特殊召唤的操作信息。
function c29280589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取发动玩家当前可用的融合素材组（手卡·场上的怪兽及额外素材效果提供的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 用普通融合素材组检查额外卡组中是否存在符合条件的「魔玩具」融合怪兽，以确定能否融合召唤。
		local res=Duel.IsExistingMatchingCard(c29280589.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取连锁素材效果（例如允许使用额外区域或对方场上素材的效果），用于扩展融合素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若普通素材无法达成，则改用连锁素材效果提供的素材组再次检查额外卡组中是否存在可融合召唤的「魔玩具」融合怪兽。
				res=Duel.IsExistingMatchingCard(c29280589.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本次效果将在处理时从额外卡组把1只怪兽特殊召唤（融合召唤），供相关卡片检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从额外卡组选择1只「魔玩具」融合怪兽，选择对应的融合素材（必须包含手卡的这张卡），将素材送入墓地，并以融合召唤方式特殊召唤该怪兽；若使用连锁素材效果则按连锁素材效果执行。
function c29280589.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取通常融合素材组，并排除对当前效果免疫的卡，得到可实际使用的素材集合。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c29280589.filter1,nil,e)
	-- 用可用的通常素材组，从额外卡组筛选出所有可以进行融合召唤的「魔玩具」融合怪兽，作为候选。
	local sg1=Duel.GetMatchingGroup(c29280589.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取连锁素材效果（为处理分支做准备）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材效果提供的素材组及额外条件，筛选额外卡组中可融合召唤的「魔玩具」融合怪兽，得到另一组候选。
		sg2=Duel.GetMatchingGroup(c29280589.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向发动者显示选择提示，请其选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否在通常素材候选组中，且（若也在连锁素材候选组中）玩家未选择使用连锁素材；成立则使用通常素材，否则使用连锁素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让发动者从通常素材组中选择该融合怪兽所需的融合素材（必须包含手卡的这张卡）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以融合召唤素材的形式送入墓地（原因包含效果、素材、融合）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续特殊召唤处理被视为不同的时点，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式特殊召唤到发动者场上（表侧表示）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材效果，则从连锁素材提供的素材组中选择融合素材（同样必须包含手卡的这张卡）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的被破坏怪兽过滤：自己场上表侧表示的「魔玩具」融合怪兽，因战斗或效果被破坏，且不是被代替破坏的处理。
function c29280589.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0xad)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的触发判定：此卡在墓地且可以除外，并且场上存在符合条件的将被破坏的「魔玩具」融合怪兽；玩家选择发动后，除外此卡并返回true，代替该怪兽被破坏。
function c29280589.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c29280589.repfilter,1,nil,tp) end
	-- 询问发动者是否发动②效果，用墓地中的这张卡代替破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将此卡从墓地除外，作为代替破坏的代价。
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- ②效果的value函数：对被破坏的怪兽逐一判断是否满足自己场上「魔玩具」融合怪兽且因战斗·效果被破坏的条件，供系统确认是否使用代替破坏。
function c29280589.repval(e,c)
	return c29280589.repfilter(c,e:GetHandlerPlayer())
end
