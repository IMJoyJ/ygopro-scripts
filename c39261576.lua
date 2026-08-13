--パーティカル・フュージョン
-- 效果：
-- 从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果融合召唤成功时，把墓地存在的这张卡从游戏中除外，选择那次融合召唤使用的1只名字带有「宝石骑士」的融合素材怪兽发动。那只融合怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
function c39261576.initial_effect(c)
	-- 从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39261576.target)
	e1:SetOperation(c39261576.activate)
	c:RegisterEffect(e1)
	-- 这个效果融合召唤成功时，把墓地存在的这张卡从游戏中除外，选择那次融合召唤使用的1只名字带有「宝石骑士」的融合素材怪兽发动。那只融合怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(39261576,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CUSTOM+39261576)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c39261576.atkcon)
	e2:SetCost(c39261576.atkcost)
	e2:SetTarget(c39261576.atktg)
	e2:SetOperation(c39261576.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 筛选可作为融合素材的怪兽：必须位于场上且不受此效果影响。
function c39261576.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 筛选可作为融合召唤对象的「宝石骑士」融合怪兽：必须是融合怪兽、持有「宝石骑士」字段、满足额外素材条件（若有）、能够以融合召唤方式特殊召唤，并且能用给定的素材组m进行融合召唤。
function c39261576.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动时的合法性检查：确认额外卡组存在能用己方场上素材（或连锁素材）融合召唤的「宝石骑士」融合怪兽，若存在则允许发动。
function c39261576.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方所有可作为融合素材的卡，并仅保留位于场上的卡，以满足『从自己场上』这一条件。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在符合条件的「宝石骑士」融合怪兽，且能用场上素材mg1进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c39261576.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的『连锁素材』类效果（若存在），以使用其提供的额外素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 当存在连锁素材时，使用其提供的素材组mg2及附加条件mf，再次检查是否能融合召唤出符合条件的「宝石骑士」融合怪兽。
				res=Duel.IsExistingMatchingCard(c39261576.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记本次操作信息：将从额外卡组特殊召唤1只怪兽（用于配合相关卡的发动检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤：从候选融合怪兽中选择1只，选择并送去融合素材，按融合召唤处理特殊召唤；若使用了连锁素材则调用对应处理；最后注册连锁结束时的诱发事件，以便墓地效果发动。
function c39261576.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取己方所有可作为融合素材的卡，并过滤出位于场上且不受该效果影响的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c39261576.filter1,nil,e)
	-- 取得能用通常素材mg1融合召唤的所有「宝石骑士」融合怪兽候选。
	local sg1=Duel.GetMatchingGroup(c39261576.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（若存在），用于在通常素材之外追加可用的融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材提供的素材组mg2和条件mf，取得可融合召唤的「宝石骑士」融合怪兽候选。
		sg2=Duel.GetMatchingGroup(c39261576.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发出选择提示，要求选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 如果所选怪兽能用通常素材mg1融合召唤，且不使用连锁素材（或不在连锁素材候选中/玩家选择不使用），则走通常融合素材流程；否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材mg1中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，送墓原因同时包含效果、融合素材和融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使融合召唤成为独立事件，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式、表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			e:SetLabelObject(tc)
		else
			-- 在连锁素材流程中，让玩家从连锁素材组mg2中选择该融合怪兽所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			e:SetLabelObject(tc)
		end
		tc:CompleteProcedure()
		-- 这个效果融合召唤成功时，把墓地存在的这张卡从游戏中除外，选择那次融合召唤使用的1只名字带有「宝石骑士」的融合素材怪兽发动。那只融合怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(c39261576.evop)
		e1:SetLabelObject(e)
		-- 将这个连锁结束时的诱发效果注册到玩家场地，用于在本次融合召唤的连锁结束后触发墓地效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 诱发条件：判断触发来源是否为本次融合召唤的效果（e的LabelObject所指向的e1），确保只在本次融合召唤成功时发动。
function c39261576.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 发动代价判定：墓地中的此卡可以被除外；若可以则满足发动代价。
function c39261576.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 将墓地中的此卡表侧除外，作为效果发动的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 效果对象选择：从那次融合召唤使用的素材中，选择1只「宝石骑士」怪兽作为效果对象。
function c39261576.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return chkc:IsSetCard(0x1047) and mat:IsContains(chkc) end
	if chk==0 then return mat:IsExists(Card.IsSetCard,1,nil,0x1047) end
	-- 显示选择提示，要求玩家选择1只那次融合召唤使用的「宝石骑士」素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39261576,1))  --"请选择一个使用的融合素材"
	local g=mat:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1047)
	tc:CreateEffectRelation(e)
	-- 将选择的融合素材怪兽设为当前效果的对象。
	Duel.SetTargetCard(g)
end
-- 效果处理：若融合召唤的怪兽仍与此效果关联且表侧表示，则用对象怪兽的攻击力为其提升攻击力，持续到回合结束阶段。
function c39261576.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sc=eg:GetFirst()
	if not sc:IsRelateToEffect(e) or sc:IsFacedown() then return end
	-- 获取效果对象，即被选择的融合素材怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 那只融合怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sc:RegisterEffect(e1)
end
-- 连锁结束时触发自定义事件，将本次融合召唤的怪兽作为事件对象传给墓地效果，并清除暂存信息。
function c39261576.evop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local tc=te:GetLabelObject()
	-- 引发自定义事件EVENT_CUSTOM+39261576，使墓地中的「颗粒融合」效果能够以该融合怪兽为对象发动。
	Duel.RaiseEvent(tc,EVENT_CUSTOM+39261576,te,0,tp,tp,0)
	te:SetLabelObject(nil)
	e:Reset()
end
