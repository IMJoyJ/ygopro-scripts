--パーティカル・フュージョン
-- 效果：
-- 从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。这个效果融合召唤成功时，把墓地存在的这张卡从游戏中除外，选择那次融合召唤使用的1只名字带有「宝石骑士」的融合素材怪兽发动。那只融合怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
function c39261576.initial_effect(c)
	-- 效果：从自己场上把融合怪兽卡决定的融合素材怪兽送去墓地，把名字带有「宝石骑士」的那1只融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39261576.target)
	e1:SetOperation(c39261576.activate)
	c:RegisterEffect(e1)
	-- 这个效果融合召唤成功时，把墓地存在的这张卡从游戏中除外，选择那次融合召唤使用的1只名字带有「宝石骑士」的融合素材怪兽发动。
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
-- 过滤函数：返回场上且未被效果免疫的卡。
function c39261576.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：返回融合类型、宝石骑士卡组、可特殊召唤、融合素材满足条件的卡。
function c39261576.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理：检查是否存在满足条件的融合怪兽，若无则尝试使用连锁素材效果。
function c39261576.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组，并筛选出在场上的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查是否存在满足融合条件的额外卡组融合怪兽。
		local res=Duel.IsExistingMatchingCard(c39261576.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材效果的过滤函数检查额外卡组是否存在满足条件的融合怪兽。
				res=Duel.IsExistingMatchingCard(c39261576.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：特殊召唤1只额外卡组的融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择并特殊召唤融合怪兽，处理融合素材。
function c39261576.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组，并筛选出满足条件的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c39261576.filter1,nil,e)
	-- 获取满足融合条件的额外卡组融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c39261576.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材效果的过滤函数获取额外卡组满足条件的融合怪兽组。
		sg2=Duel.GetMatchingGroup(c39261576.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一组融合怪兽，否则使用连锁素材效果。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理。
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			e:SetLabelObject(tc)
		else
			-- 选择融合怪兽的融合素材（使用连锁素材效果）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			e:SetLabelObject(tc)
		end
		tc:CompleteProcedure()
		-- 触发时点：融合召唤成功后触发攻击上升效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(c39261576.evop)
		e1:SetLabelObject(e)
		-- 注册效果：在连锁结束时触发攻击上升效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 条件函数：判断是否为融合召唤效果。
function c39261576.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
-- 费用函数：将此卡从游戏中除外作为费用。
function c39261576.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 将此卡从游戏中除外作为费用。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 目标函数：选择融合召唤使用的融合素材。
function c39261576.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return chkc:IsSetCard(0x1047) and mat:IsContains(chkc) end
	if chk==0 then return mat:IsExists(Card.IsSetCard,1,nil,0x1047) end
	-- 提示玩家选择使用的融合素材。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39261576,1))  --"请选择一个使用的融合素材"
	local g=mat:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1047)
	tc:CreateEffectRelation(e)
	-- 设置目标卡：选择的融合素材怪兽。
	Duel.SetTargetCard(g)
end
-- 效果处理：使融合怪兽攻击力上升选择的融合素材怪兽的攻击力。
function c39261576.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sc=eg:GetFirst()
	if not sc:IsRelateToEffect(e) or sc:IsFacedown() then return end
	-- 获取当前效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 效果：使融合怪兽攻击力上升选择的融合素材怪兽的攻击力。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sc:RegisterEffect(e1)
end
-- 时点处理：融合召唤成功后触发攻击上升效果。
function c39261576.evop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local tc=te:GetLabelObject()
	-- 触发攻击上升效果的时点。
	Duel.RaiseEvent(tc,EVENT_CUSTOM+39261576,te,0,tp,tp,0)
	te:SetLabelObject(nil)
	e:Reset()
end
