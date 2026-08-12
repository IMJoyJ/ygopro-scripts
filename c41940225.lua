--破壊剣士融合
-- 效果：
-- 「破坏剑士融合」的①②的效果1回合各能使用1次。
-- ①：从自己手卡以及自己·对方场上把融合怪兽卡决定的融合素材怪兽送去墓地，把以「破坏之剑士」为融合素材的那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。墓地的这张卡加入手卡。
function c41940225.initial_effect(c)
	-- ①：从自己手卡以及自己·对方场上把融合怪兽卡决定的融合素材怪兽送去墓地，把以「破坏之剑士」为融合素材的那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41940225,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41940225)
	e1:SetTarget(c41940225.target)
	e1:SetOperation(c41940225.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41940225,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,41940226)
	e2:SetCost(c41940225.thcost)
	e2:SetTarget(c41940225.thtg)
	e2:SetOperation(c41940225.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，返回场上正面表示且可以作为融合素材的怪兽
function c41940225.filter0(c)
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
end
-- 过滤函数，返回场上正面表示且可以作为融合素材且未被效果免疫的怪兽
function c41940225.filter1(c,e)
	return c:IsFaceup() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，返回满足融合召唤条件的融合怪兽，且以破坏之剑士为素材
function c41940225.filter2(c,e,tp,m,f,chkf)
	-- 判断是否为融合怪兽且以破坏之剑士为素材
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,78193831) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置融合检查附加条件，用于确保融合素材包含破坏之剑士
	aux.FCheckAdditional=c.destruction_swordsman_fusion_check or c41940225.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
	return res
end
-- 过滤函数，返回未被效果免疫的怪兽
function c41940225.filter3(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合检查函数，判断融合素材组是否包含破坏之剑士
function c41940225.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,78193831)
end
-- 判断是否存在满足融合召唤条件的融合怪兽
function c41940225.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取玩家场上正面表示且可以作为融合素材的怪兽
		local mg2=Duel.GetMatchingGroup(c41940225.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c41940225.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合召唤条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c41940225.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果处理函数
function c41940225.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用的融合素材组并过滤掉被效果免疫的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c41940225.filter3,nil,e)
	-- 获取玩家场上正面表示且可以作为融合素材且未被效果免疫的怪兽
	local mg2=Duel.GetMatchingGroup(c41940225.filter1,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c41940225.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合召唤条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c41940225.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设置融合检查附加条件，用于确保融合素材包含破坏之剑士
		aux.FCheckAdditional=tc.destruction_swordsman_fusion_check or c41940225.fcheck
		-- 判断是否使用普通融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合召唤所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
end
-- 墓地效果的费用支付函数
function c41940225.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可以作为费用送入墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 将1张手牌送入墓地作为费用
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 墓地效果的发动处理函数
function c41940225.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地效果的发动处理函数
function c41940225.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡加入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
