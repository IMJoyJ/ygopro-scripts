--地雷星トドロキ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力下降500。
-- ②：自己·对方的战斗阶段支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c30118701.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把手卡1只其他怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30118701,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30118701+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c30118701.hspcon)
	e1:SetTarget(c30118701.hsptg)
	e1:SetOperation(c30118701.hspop)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：自己·对方的战斗阶段支付500基本分才能发动。从自己的手卡·场上把战士族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30118701,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30118702)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCondition(c30118701.spcon)
	e2:SetCost(c30118701.spcost)
	e2:SetTarget(c30118701.sptg)
	e2:SetOperation(c30118701.spop)
	c:RegisterEffect(e2)
end
-- 特殊召唤代价的过滤条件：手卡中的这张卡必须是怪兽且可以作为代价送去墓地。
function c30118701.hspcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①特殊召唤的规则条件：此卡在手卡时，自己场上有空位，且手卡中存在除自身外可作为代价送去墓地的其他怪兽（c为nil时表示询问是否有可特殊召唤的情况）。
function c30118701.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的主要怪兽区是否存在至少1个可用的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身外1张可以作为代价送去墓地的其他怪兽。
		and Duel.IsExistingMatchingCard(c30118701.hspcfilter,tp,LOCATION_HAND,0,1,c)
end
-- ①特殊召唤的处理：从手卡选择1只除自身外的其他怪兽作为送去墓地的代价，并将选中的卡保存在效果中供后续处理使用。
function c30118701.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中所有可作为代价送去墓地的其他怪兽（不包括这张卡本身）的集合。
	local g=Duel.GetMatchingGroup(c30118701.hspcfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家显示选择提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 完成①的特殊召唤：将选择的代价怪兽送去墓地，使这张卡特殊召唤成功，并为其附加攻击力下降500的效果。
function c30118701.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为代价的怪兽送去墓地（原因标记为特殊召唤手续）。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 这个方法特殊召唤的这张卡的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件：当前阶段为自己或对方的战斗阶段。
function c30118701.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束之间）。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- ②效果的发动代价：支付500基本分。
function c30118701.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己当前能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 过滤出不受当前效果影响的卡，用于从融合素材中将免疫的卡排除。
function c30118701.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 筛选额外卡组中符合条件的融合怪兽：必须是战士族融合怪兽、能够通过融合召唤特殊召唤，并且可以用给定的素材组作为融合素材。
function c30118701.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动目标检查：在发动时确认额外卡组是否存在可融合召唤的战士族融合怪兽（支持通常素材和连锁素材两种方式），若存在则登记从额外卡组特殊召唤的操作信息。
function c30118701.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材组（包括手卡·场上的怪兽以及受追加融合素材效果影响的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在至少1只能够使用当前素材融合召唤的战士族融合怪兽。
		local res=Duel.IsExistingMatchingCard(c30118701.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取自己适用的‘连锁素材’等替代融合素材效果（若有）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材，则用其提供的替代素材组再次检查额外卡组中是否存在可融合召唤的战士族融合怪兽。
				res=Duel.IsExistingMatchingCard(c30118701.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本效果将要从额外卡组特殊召唤1只怪兽的操作信息，以供相关卡片响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从可选的战士族融合怪兽中选择1只，再选择一组融合素材送去墓地，将其融合召唤到场上；若选择使用连锁素材的替代处理，则按连锁素材效果完成融合召唤。
function c30118701.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得通常融合素材组，并过滤掉对当前效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c30118701.spfilter1,nil,e)
	-- 从额外卡组筛选出所有能够用通常素材融合召唤且符合条件的战士族融合怪兽。
	local sg1=Duel.GetMatchingGroup(c30118701.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取自己适用的连锁素材效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，则用其替代素材组筛选出可以融合召唤的战士族融合怪兽。
		sg2=Duel.GetMatchingGroup(c30118701.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否来自通常素材可召唤的集合，且（不存在连锁素材或玩家选择不使用连锁素材），若是则走通常融合召唤流程，否则走连锁素材替代流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常素材组中为所选融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材按效果·素材·融合召唤的理由送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果的处理，使后续融合召唤视为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示特殊召唤到自己的怪兽区域，完成融合召唤（召唤方式标记为融合召唤）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材效果，则从其提供的素材组中为所选融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
