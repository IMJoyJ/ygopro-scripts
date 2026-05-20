--Aiラブ融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把电子界族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。把自己的「@火灵天星」怪兽作为融合素材的场合，对方场上的连接怪兽也能有最多1只作为融合素材。
function c59332125.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上把电子界族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。把自己的「@火灵天星」怪兽作为融合素材的场合，对方场上的连接怪兽也能有最多1只作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,59332125+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c59332125.target)
	e1:SetOperation(c59332125.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上可以作为融合素材的表侧表示连接怪兽
function c59332125.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsCanBeFusionMaterial()
end
-- 过滤不受效果影响的卡片（用于融合素材）
function c59332125.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤对方场上不受效果影响且可以作为融合素材的表侧表示连接怪兽
function c59332125.filter3(c,e)
	return c59332125.filter1(c) and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的电子界族融合怪兽
function c59332125.spfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_CYBERSE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤自己场上或手卡的「@火灵天星」怪兽
function c59332125.chkfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x135)
end
-- 融合素材合法性检查：若包含自己的「@火灵天星」怪兽，则最多可使用1张对方场上的卡作为素材，否则不能使用对方场上的卡
function c59332125.fcheck(tp,sg,fc)
	if sg:IsExists(c59332125.chkfilter,1,nil,tp) then
		return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
	else
		return sg:FilterCount(Card.IsControler,nil,1-tp)<=0
	end
end
-- 融合素材选择数量限制：选择对方场上的卡作为素材时最多只能选择1张
function c59332125.gcheck(tp)
	return	function(sg)
				return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
			end
end
-- 效果发动的准备与合法性检测（Target阶段）
function c59332125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的常规融合素材（手卡·场上）
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取对方场上符合条件的连接怪兽作为潜在融合素材
		local mg2=Duel.GetMatchingGroup(c59332125.filter1,tp,0,LOCATION_MZONE,nil)
		if mg1:IsExists(c59332125.chkfilter,1,nil,tp) and mg2:GetCount()>0 then
			mg1:Merge(mg2)
			-- 设置额外的融合素材合法性检查函数
			aux.FCheckAdditional=c59332125.fcheck
			-- 设置额外的融合素材选择数量限制函数
			aux.GCheckAdditional=c59332125.gcheck(tp)
		end
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的电子界族融合怪兽
		local res=Duel.IsExistingMatchingCard(c59332125.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 重置额外融合素材合法性检查函数
		aux.FCheckAdditional=nil
		-- 重置额外融合素材选择数量限制函数
		aux.GCheckAdditional=nil
		if not res then
			-- 检查是否存在如「连锁素材」等影响融合召唤的卡片效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在受「连锁素材」等效果影响时，检查是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(c59332125.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤的操作信息（用于连锁处理）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理的执行（Activate阶段）
function c59332125.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用且不受此卡效果影响的常规融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c59332125.filter2,nil,e)
	-- 获取对方场上不受此卡效果影响且符合条件的连接怪兽
	local mg2=Duel.GetMatchingGroup(c59332125.filter3,tp,0,LOCATION_MZONE,nil,e)
	local exmat=false
	if mg1:IsExists(c59332125.chkfilter,1,nil,tp) and mg2:GetCount()>0 then
		mg1:Merge(mg2)
		exmat=true
	end
	if exmat then
		-- 效果处理时，设置额外的融合素材合法性检查函数
		aux.FCheckAdditional=c59332125.fcheck
		-- 效果处理时，设置额外的融合素材选择数量限制函数
		aux.GCheckAdditional=c59332125.gcheck(tp)
	end
	-- 过滤出当前素材可以融合召唤的额外卡组怪兽
	local sg1=Duel.GetMatchingGroup(c59332125.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 过滤完毕后，重置额外融合素材合法性检查函数
	aux.FCheckAdditional=nil
	-- 过滤完毕后，重置额外融合素材选择数量限制函数
	aux.GCheckAdditional=nil
	local mg3=nil
	local sg2=nil
	-- 效果处理时，检查是否存在「连锁素材」等效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 过滤出在「连锁素材」等效果下可以融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(c59332125.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	local sg=sg1:Clone()
	if sg2 then sg:Merge(sg2) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	-- 判断是否使用本卡自身的效果进行融合召唤（而非「连锁素材」等其他效果）
	if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
		if exmat then
			-- 确定进行本卡融合后，重新设置额外的融合素材合法性检查函数
			aux.FCheckAdditional=c59332125.fcheck
			-- 确定进行本卡融合后，重新设置额外的融合素材选择数量限制函数
			aux.GCheckAdditional=c59332125.gcheck(tp)
		end
		-- 玩家选择用于融合召唤该怪兽的融合素材
		local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
		-- 素材选择完毕后，重置额外融合素材合法性检查函数
		aux.FCheckAdditional=nil
		-- 素材选择完毕后，重置额外融合素材选择数量限制函数
		aux.GCheckAdditional=nil
		tc:SetMaterial(mat1)
		-- 将选定的融合素材怪兽送去墓地
		Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		-- 产生时点中断，使后续的特殊召唤不与送去墓地同时处理
		Duel.BreakEffect()
		-- 将融合怪兽从额外卡组进行融合召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	else
		-- 在使用「连锁素材」等效果时，选择对应的融合素材
		local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
		local fop=ce:GetOperation()
		fop(ce,e,tp,tc,mat2)
	end
	tc:CompleteProcedure()
end
