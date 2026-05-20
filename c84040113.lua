--ドロドロゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：融合怪兽融合召唤的场合，场上·墓地的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
-- ②：这张卡是已同调召唤的场合，自己主要阶段才能发动。包含这张卡的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
function c84040113.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ②：这张卡是已同调召唤的场合，自己主要阶段才能发动。包含这张卡的自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,84040113)
	e1:SetCondition(c84040113.spcon)
	e1:SetTarget(c84040113.sptg)
	e1:SetOperation(c84040113.spop)
	c:RegisterEffect(e1)
	-- ①：融合怪兽融合召唤的场合，场上·墓地的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(c84040113.subcon)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否在手卡、场上或墓地（作为融合素材代用效果的适用条件）
function c84040113.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 检查这张卡是否是已同调召唤的状态
function c84040113.spcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤场上不受该效果影响的怪兽，用于筛选融合素材
function c84040113.spfilter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以融合召唤的融合怪兽，且必须以这张卡作为融合素材
function c84040113.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 融合召唤效果的发动准备与合法性检查（Target阶段）
function c84040113.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在可以使用场上素材（包含这张卡）进行融合召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(c84040113.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下，是否存在可以融合召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(c84040113.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示此效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的具体处理（Operation阶段）
function c84040113.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己场上不受该效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c84040113.spfilter1,nil,e)
	-- 获取使用场上素材可以融合召唤的融合怪兽集合
	local sg1=Duel.GetMatchingGroup(c84040113.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果适用下可以融合召唤的融合怪兽集合
		sg2=Duel.GetMatchingGroup(c84040113.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（而非连锁素材的效果）进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材（必须包含这张卡）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材效果适用下，让玩家选择融合素材（必须包含这张卡）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
