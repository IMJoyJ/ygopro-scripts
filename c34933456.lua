--聖なる法典
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上把融合怪兽卡决定的包含魔法师族怪兽的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。「大贤者」融合怪兽融合召唤的场合，给「大贤者」怪兽装备的自己的魔法与陷阱区域的当作装备卡使用的融合素材怪兽也能作为融合素材使用。
function c34933456.initial_effect(c)
	-- 创建效果并注册，设置为自由时点、只能发动一次、目标为特殊召唤和融合召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34933456+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34933456.target)
	e1:SetOperation(c34933456.activate)
	c:RegisterEffect(e1)
end
-- 判断装备卡是否为大贤者系列且为怪兽类型
function c34933456.mttg(e,c)
	local tc=c:GetEquipTarget()
	return tc and tc:IsSetCard(0x150) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断融合素材是否为大贤者系列
function c34933456.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(0x150)
end
-- 过滤满足融合召唤条件的融合怪兽
function c34933456.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤不被效果免疫的卡片
function c34933456.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检查融合素材中是否存在魔法师族怪兽
function c34933456.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsRace,nil,1,RACE_SPELLCASTER)
end
-- 判断是否可以发动此效果，检查是否有满足条件的融合怪兽
function c34933456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 将效果注册为玩家的场地区域融合素材增加效果
		local me=Effect.CreateEffect(e:GetHandler())
		me:SetType(EFFECT_TYPE_FIELD)
		me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		me:SetTargetRange(LOCATION_SZONE,0)
		me:SetTarget(c34933456.mttg)
		me:SetValue(c34933456.mtval)
		-- 将融合素材效果注册给全局环境
		Duel.RegisterEffect(me,tp)
		local chkf=tp
		-- 获取玩家当前可用的融合素材组
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合检查附加条件为魔法师族
		aux.FCheckAdditional=c34933456.fcheck
		-- 检查额外卡组是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c34933456.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查连锁融合素材是否满足条件
				res=Duel.IsExistingMatchingCard(c34933456.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		-- 清除融合检查附加条件
		aux.FCheckAdditional=nil
		me:Reset()
		return res
	end
	-- 设置操作信息，表示将要特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动的主函数，执行融合召唤流程
function c34933456.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果注册为玩家的场地区域融合素材增加效果
	local me=Effect.CreateEffect(e:GetHandler())
	me:SetType(EFFECT_TYPE_FIELD)
	me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	me:SetTargetRange(LOCATION_SZONE,0)
	me:SetTarget(c34933456.mttg)
	me:SetValue(c34933456.mtval)
	-- 将融合素材效果注册给全局环境
	Duel.RegisterEffect(me,tp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材组并过滤掉免疫效果的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c34933456.filter2,nil,e)
	-- 设置融合检查附加条件为魔法师族
	aux.FCheckAdditional=c34933456.fcheck
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c34933456.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取连锁融合素材中满足条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c34933456.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材选择方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 清除融合检查附加条件
	aux.FCheckAdditional=nil
	me:Reset()
end
