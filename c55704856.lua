--サイバーロード・フュージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己场上以及除外的自己怪兽之中让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「电子龙」怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。这个回合，这个效果特殊召唤的怪兽以外的自己怪兽不能攻击。
function c55704856.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己场上以及除外的自己怪兽之中让融合怪兽卡决定的融合素材怪兽回到持有者卡组，把以「电子龙」怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。这个回合，这个效果特殊召唤的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,55704856+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c55704856.target)
	e1:SetOperation(c55704856.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上或表侧表示除外的、可作为融合素材且能回到卡组的怪兽
function c55704856.filter0(c)
	return (c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 过滤条件：场上或表侧表示除外的、可作为融合素材、能回到卡组且不受当前效果影响的怪兽
function c55704856.filter1(c,e)
	return (c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以被融合召唤、且以「电子龙」怪兽为素材的融合怪兽
function c55704856.filter2(c,e,tp,m,f,chkf)
	-- 检查怪兽是否为融合怪兽，且其融合素材列表中是否包含「电子龙」怪兽
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListSetCard(c,0x1093) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置额外的融合素材检查函数，确保融合素材中包含「电子龙」怪兽
	aux.FCheckAdditional=c.cyber_fusion_check or c55704856.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置额外融合素材检查函数
	aux.FCheckAdditional=nil
	return res
end
-- 过滤条件：可作为融合素材且能回到卡组的怪兽卡
function c55704856.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end
-- 额外融合素材检查：选中的融合素材中必须包含至少1张「电子龙」怪兽
function c55704856.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x1093)
end
-- 效果发动的目标检查与准备阶段
function c55704856.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上以及除外的自己怪兽中满足条件的卡片组作为融合素材
		local mg=Duel.GetMatchingGroup(c55704856.filter0,tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil)
		-- 获取玩家可用的融合素材，并过滤掉手牌中的卡
		local mg2=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsLocation),nil,LOCATION_HAND)
		mg:Merge(mg2)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的、以「电子龙」怪兽为素材的融合怪兽
		local res=Duel.IsExistingMatchingCard(c55704856.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			-- 检查玩家是否存在受「连锁素材」等效果影响的可用融合素材
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在「连锁素材」效果下，额外卡组是否存在可融合召唤的合法怪兽
				res=Duel.IsExistingMatchingCard(c55704856.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行阶段
function c55704856.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上以及除外的自己怪兽中满足条件且不受当前效果影响的卡片组作为融合素材
	local mg=Duel.GetMatchingGroup(c55704856.filter1,tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil,e)
	-- 获取玩家可用的融合素材，并过滤掉手牌中的卡
	local mg2=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsLocation),nil,LOCATION_HAND)
	mg:Merge(mg2)
	-- 获取额外卡组中可以使用当前素材进行融合召唤的合法融合怪兽组
	local sg1=Duel.GetMatchingGroup(c55704856.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 检查玩家是否受到「连锁素材」等效果的影响
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在「连锁素材」效果下，额外卡组中可融合召唤的合法怪兽组
		sg2=Duel.GetMatchingGroup(c55704856.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设置所选融合怪兽对应的额外素材检查函数（确保包含「电子龙」怪兽）
		aux.FCheckAdditional=tc.cyber_fusion_check or c55704856.fcheck
		-- 判断是否使用常规融合素材进行融合召唤（若不使用「连锁素材」的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用素材中选择用于融合召唤该怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 给对方玩家确认里侧表示的融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(c55704856.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(c55704856.cfilter,nil)
				-- 选中并闪烁显示场上表侧表示或除外区被选为素材的怪兽
				Duel.HintSelection(cg)
			end
			-- 将选中的融合素材怪兽送回持有者卡组并洗牌
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送回卡组视为同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽从额外卡组表侧表示融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在「连锁素材」效果下，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(55704856,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个回合，这个效果特殊召唤的怪兽以外的自己怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c55704856.ftarget)
		e1:SetLabel(fid)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能攻击的全局效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 重置额外融合素材检查函数
	aux.FCheckAdditional=nil
end
-- 过滤条件：处于除外区，或者在场上表侧表示存在的卡（用于在送回卡组前进行提示显示）
function c55704856.cfilter(c)
	return c:IsLocation(LOCATION_REMOVED) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
end
-- 过滤条件：用于攻击限制效果，筛选出除本次特殊召唤的怪兽以外的自己场上的怪兽
function c55704856.ftarget(e,c)
	return e:GetLabel()~=c:GetFlagEffectLabel(55704856)
end
