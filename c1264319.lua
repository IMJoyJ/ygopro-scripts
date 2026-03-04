--ジェムナイト・フュージョン
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只「宝石骑士」怪兽除外才能发动。这张卡加入手卡。
function c1264319.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1264319,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1264319.target)
	e1:SetOperation(c1264319.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把1只「宝石骑士」怪兽除外才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(1264319,1))  --"加入手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c1264319.thcost)
	e2:SetTarget(c1264319.thtg)
	e2:SetOperation(c1264319.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否免疫效果
function c1264319.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断怪兽是否满足融合召唤条件
function c1264319.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c1264319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c1264319.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c1264319.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理函数，用于执行融合召唤操作
function c1264319.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材并过滤掉免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c1264319.filter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c1264319.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c1264319.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的连锁融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于判断墓地中的怪兽是否为宝石骑士族且可作为除外费用
function c1264319.thfilter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的处理函数，用于支付除外费用
function c1264319.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c1264319.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择要除外的怪兽
	local g=Duel.SelectMatchingCard(tp,c1264319.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的处理函数，用于设置效果目标
function c1264319.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将此卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理函数，用于执行效果
function c1264319.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 确认对方查看此卡
		Duel.ConfirmCards(1-tp,c)
	end
end
