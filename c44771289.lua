--旅人の結彼岸
-- 效果：
-- ①：从自己的手卡·场上把「彼岸」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到下次的对方回合结束时上升800。这个效果在这张卡送去墓地的回合不能发动。
function c44771289.initial_effect(c)
	-- ①：从自己的手卡·场上把「彼岸」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44771289,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44771289.target)
	e1:SetOperation(c44771289.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以场上1只「彼岸」怪兽为对象才能发动。那只怪兽的攻击力·守备力直到下次的对方回合结束时上升800。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44771289,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置②效果的发动条件为“这张卡送去墓地的回合不能发动”。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动COST为把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44771289.atktg)
	e2:SetOperation(c44771289.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：排除对当前效果免疫的融合素材卡。
function c44771289.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：判定额外卡组的融合怪兽是否为「彼岸」融合怪兽、能否被融合召唤，并且当前素材组是否能满足其融合素材要求。
function c44771289.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xb1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动条件检测：确认额外卡组存在可融合召唤的「彼岸」融合怪兽，且当前素材（含连锁素材替代）能满足其素材要求；满足后登记特殊召唤信息。
function c44771289.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用于融合召唤的素材组（手卡·场上的怪兽以及额外融合素材效果适用的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在至少1只能用当前普通融合素材融合召唤的符合条件的「彼岸」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c44771289.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取“连锁素材”类替代融合素材效果（若存在）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的替代素材组重新检查额外卡组是否存在可融合召唤的目标。
				res=Duel.IsExistingMatchingCard(c44771289.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次效果将从额外卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的融合召唤处理：选择1只符合条件的「彼岸」融合怪兽，选择融合素材送去墓地，进行融合召唤；若使用连锁素材则按其效果执行融合召唤。
function c44771289.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前玩家可用的融合素材组，并排除对此效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44771289.filter1,nil,e)
	-- 获取所有在当前普通素材下可融合召唤的「彼岸」融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c44771289.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取“连锁素材”类替代融合素材效果（若存在）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取所有在连锁素材替代素材下可融合召唤的「彼岸」融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c44771289.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否走普通融合流程（若在普通候选组中，且没有连锁素材候选或玩家选择不使用连锁素材）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从普通融合素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，原因记为效果、素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选择的怪兽表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁素材提供的素材组中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义效果对象筛选条件：场上表侧表示的「彼岸」怪兽。
function c44771289.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb1)
end
-- 效果②的发动条件与取对象处理：确认场上存在可选择的表侧「彼岸」怪兽，并选择其中1只为对象。
function c44771289.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44771289.atkfilter(chkc) end
	-- 效果发动时检查场上是否存在至少1只表侧表示的「彼岸」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c44771289.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示的「彼岸」怪兽作为效果对象，并设为当前连锁的对象。
	Duel.SelectTarget(tp,c44771289.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理：将对象怪兽的攻击力·守备力直到下次对方回合结束时各上升800。
function c44771289.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到下次的对方回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
