--ウィッチクラフト・コンフュージョン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的手卡·场上把融合怪兽卡决定的包含「魔女术」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
function c35098357.initial_effect(c)
	-- ①：从自己的手卡·场上把融合怪兽卡决定的包含「魔女术」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35098357)
	e1:SetTarget(c35098357.target)
	e1:SetOperation(c35098357.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35098357)
	e2:SetCondition(c35098357.thcon)
	e2:SetTarget(c35098357.thtg)
	e2:SetOperation(c35098357.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断卡片是否免疫当前效果
function c35098357.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于判断卡片是否为融合怪兽且满足特殊召唤条件和融合素材条件
function c35098357.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合检查函数，用于判断融合素材中是否包含「魔女术」种族的怪兽
function c35098357.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0x128)
end
-- 效果处理时检查是否存在满足条件的融合怪兽，用于判断是否可以发动效果
function c35098357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材卡片组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合检查附加条件为自定义的fcheck函数
		aux.FCheckAdditional=c35098357.fcheck
		-- 检查是否存在满足融合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c35098357.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 取消设置融合检查附加条件
		aux.FCheckAdditional=nil
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c35098357.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，用于执行融合召唤操作
function c35098357.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材卡片组并过滤掉免疫效果的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c35098357.filter1,nil,e)
	-- 设置融合检查附加条件为自定义的fcheck函数
	aux.FCheckAdditional=c35098357.fcheck
	-- 获取满足融合条件的融合怪兽卡片组
	local sg1=Duel.GetMatchingGroup(c35098357.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 取消设置融合检查附加条件
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽卡片组
		sg2=Duel.GetMatchingGroup(c35098357.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的融合怪兽是否来自基础融合素材组或是否需要确认连锁融合
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置融合检查附加条件为自定义的fcheck函数
			aux.FCheckAdditional=c35098357.fcheck
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 取消设置融合检查附加条件
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的连锁融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于判断卡片是否为「魔女术」种族且表侧表示
function c35098357.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果发动条件函数，判断是否满足发动②效果的条件
function c35098357.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
		-- 判断效果发动者场上是否存在「魔女术」种族的怪兽
		and Duel.IsExistingMatchingCard(c35098357.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理函数，用于设置发动②效果时的操作信息
function c35098357.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将要将卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，用于执行②效果的处理
function c35098357.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
