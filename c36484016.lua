--ミラクルシンクロフュージョン
-- 效果：
-- ①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把以同调怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
function c36484016.initial_effect(c)
	-- 效果①：从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把以同调怪兽为融合素材的那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36484016.target)
	e1:SetOperation(c36484016.activate)
	c:RegisterEffect(e1)
	-- 效果②：盖放的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36484016,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36484016.drcon)
	e2:SetTarget(c36484016.drtg)
	e2:SetOperation(c36484016.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：返回场上且能除外的卡片
function c36484016.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
-- 过滤函数：返回场上且能除外且未被效果免疫的卡片
function c36484016.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数：返回满足融合召唤条件的融合怪兽卡片
function c36484016.filter2(c,e,tp,m,f,chkf)
	-- 判断卡片是否为融合怪兽且其融合素材包含同调怪兽类型
	if not (c:IsType(TYPE_FUSION) and aux.IsMaterialListType(c,TYPE_SYNCHRO) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设置融合检查附加条件为同调类型检查函数
	aux.FCheckAdditional=c.synchro_fusion_check or c36484016.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
	return res
end
-- 过滤函数：返回可作为融合素材的怪兽卡片
function c36484016.filter4(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 融合检查附加条件函数：判断素材组是否包含同调类型怪兽
function c36484016.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionType,1,nil,TYPE_SYNCHRO)
end
-- 效果①的发动条件判断：检索满足条件的融合怪兽并确认是否能发动
function c36484016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组并筛选出能除外的卡片
		local mg1=Duel.GetFusionMaterial(tp):Filter(c36484016.filter0,nil)
		-- 获取玩家墓地中的可除外怪兽卡片组
		local mg2=Duel.GetMatchingGroup(c36484016.filter4,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c36484016.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c36484016.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：将要特殊召唤的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：将要除外的融合素材
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果①的发动处理：选择融合怪兽并进行融合召唤
function c36484016.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组并筛选出能除外且未被免疫的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c36484016.filter1,nil,e)
	-- 获取玩家墓地中的可除外怪兽卡片组
	local mg2=Duel.GetMatchingGroup(c36484016.filter4,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c36484016.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c36484016.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 设置融合检查附加条件为同调类型检查函数
		aux.FCheckAdditional=tc.synchro_fusion_check or c36484016.fcheck
		-- 判断是否使用普通融合素材选择方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（连锁方式）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
end
-- 效果②的发动条件判断：确认盖放的此卡被对方效果破坏送入墓地
function c36484016.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 效果②的发动处理：设置抽卡目标
function c36484016.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：目标玩家为自身
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置操作信息：将要抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的发动处理：执行抽卡效果
function c36484016.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
