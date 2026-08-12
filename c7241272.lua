--獄炎のカース・オブ・ドラゴン
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张场地魔法卡为对象才能发动。那张卡破坏。
-- ②：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c7241272.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张场地魔法卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7241272,0))  --"场地魔法卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c7241272.destg)
	e1:SetOperation(c7241272.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7241272,1))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c7241272.sptg)
	e3:SetOperation(c7241272.spop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件与对象选择（Target）函数
function c7241272.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) end
	-- 在发动阶段（chk==0），检查场上是否存在可以作为对象的场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张场地魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 设置效果处理信息，包含破坏分类和选中的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①号效果的效果处理（Operation）函数
function c7241272.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：筛选场上不受当前效果影响的融合素材卡片
function c7241272.spfilter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：筛选额外卡组中可以进行融合召唤，且能以当前可用卡片（包含这张卡）作为素材的融合怪兽
function c7241272.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ②号效果的发动条件判定（Target）函数
function c7241272.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在可以包含这张卡作为素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c7241272.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材（如连锁素材/Chain Material）效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在连锁素材效果存在时，检查是否能使用其指定的素材进行融合召唤
				res=Duel.IsExistingMatchingCard(c7241272.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息，包含从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②号效果的效果处理（Operation）函数
function c7241272.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取自己场上不受此效果影响的可用融合素材卡片组
	local mg1=Duel.GetFusionMaterial(tp):Filter(c7241272.spfilter1,nil,e)
	-- 获取额外卡组中可以使用场上素材（包含这张卡）进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(c7241272.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(c7241272.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若只能用常规方式，或玩家在可选时选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择包含这张卡在内的、用于融合召唤目标怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材因效果、作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送去墓地同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
