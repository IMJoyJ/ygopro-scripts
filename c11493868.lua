--フォルテッシモ
-- 效果：
-- ①：1回合1次，以自己场上1只「幻奏」怪兽为对象才能把这个效果发动。那只怪兽的攻击力直到下次的自己准备阶段上升800。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。「幻奏」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c11493868.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只「幻奏」怪兽为对象才能把这个效果发动。那只怪兽的攻击力直到下次的自己准备阶段上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11493868,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c11493868.atktg)
	e2:SetOperation(c11493868.atkop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。「幻奏」融合怪兽卡决定的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11493868,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c11493868.cost)
	e3:SetTarget(c11493868.target)
	e3:SetOperation(c11493868.activate)
	c:RegisterEffect(e3)
end
-- 定义「幻奏」怪兽的筛选条件：必须是表侧表示且卡名含有0x9b（「幻奏」）字段。
function c11493868.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- ①效果的发动时点处理：检查能否选择对象，若可以则选择1只自己场上的表侧表示「幻奏」怪兽，并设置攻击力变化信息。
function c11493868.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11493868.atkfilter(chkc) end
	-- 发动合法性检查：确认自己场上是否存在至少1只表侧表示且属于「幻奏」字段的怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c11493868.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示且属于「幻奏」字段的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c11493868.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将对1只对象怪兽造成攻击力变化，上升800点。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,800)
end
-- ①效果处理：若对象怪兽仍在场上且表侧表示，且与效果仍有联系，则赋予其攻击力上升800的效果，持续到下次自己准备阶段。
function c11493868.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到下次的自己准备阶段上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetValue(800)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的代价判定与支付：确认魔法与陷阱区域表侧表示的这张卡可以被送去墓地作为代价，并执行送去墓地的操作。
function c11493868.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将魔法与陷阱区域表侧表示的这张卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 融合素材过滤条件：只能使用场上的怪兽作为融合素材，且该怪兽不免疫此效果。
function c11493868.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤条件：必须是「幻奏」融合怪兽，能够被融合召唤，且满足当前可用素材的融合素材条件。
function c11493868.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x9b) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动条件判定：确认存在可用当前场上素材融合召唤的「幻奏」融合怪兽；若通常素材不够，则检查是否有连锁素材效果可替代。
function c11493868.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得玩家可用的所有融合素材，并筛选出仅限场上的怪兽作为本次融合素材候选。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组中是否存在1只能用这些场上素材融合召唤的「幻奏」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c11493868.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家拥有的连锁素材效果（可替代融合素材的特殊效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果提供的素材，检查额外卡组中是否存在1只可融合召唤的「幻奏」融合怪兽。
				res=Duel.IsExistingMatchingCard(c11493868.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果包含从额外卡组特殊召唤1只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从候选的「幻奏」融合怪兽中选择1只，再根据选择的素材来源（通常素材或连锁素材）将素材送去墓地并进行融合召唤。
function c11493868.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得通常可用的融合素材，并过滤掉免疫此效果的卡，只保留场上的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c11493868.filter1,nil,e)
	-- 取得额外卡组中所有能用当前通常素材融合召唤的「幻奏」融合怪兽。
	local sg1=Duel.GetMatchingGroup(c11493868.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 再次获取连锁素材效果（用于判断是否有替代素材可用）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，取得用连锁素材提供的素材可融合召唤的候选「幻奏」融合怪兽。
		sg2=Duel.GetMatchingGroup(c11493868.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示框。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 若选中的融合怪兽在通常素材候选中，且没有使用连锁素材效果（或玩家选择不使用连锁素材），则执行通常融合流程，否则执行连锁素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从通常融合素材中为该融合怪兽选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材从场上送去墓地（作为融合素材送去墓地）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤被视为新的效果处理，避免错失时点。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示特殊召唤到自己的主要怪兽区（融合召唤）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材中为该融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
