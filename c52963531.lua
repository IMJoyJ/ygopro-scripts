--EMマンモスプラッシュ
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，自己场上有融合怪兽特殊召唤时才能发动。从自己的额外卡组把1只表侧表示的「异色眼」灵摆怪兽特殊召唤。
-- 【怪兽效果】
-- 「娱乐伙伴 洒水猛犸」的怪兽效果在决斗中只能使用1次。
-- ①：自己主要阶段才能发动。从自己场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c52963531.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和发动灵摆卡
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己场上有融合怪兽特殊召唤时才能发动。从自己的额外卡组把1只表侧表示的「异色眼」灵摆怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetCondition(c52963531.spcon)
	e2:SetTarget(c52963531.sptg)
	e2:SetOperation(c52963531.spop)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。从自己场上把龙族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,52963531+EFFECT_COUNT_CODE_DUEL)
	e3:SetTarget(c52963531.target)
	e3:SetOperation(c52963531.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上的融合怪兽是否满足条件
function c52963531.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 效果触发条件，检查是否有融合怪兽数量满足条件
function c52963531.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52963531.cfilter,1,nil,tp)
end
-- 特殊召唤过滤函数，筛选符合条件的灵摆怪兽
function c52963531.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM)
		-- 检查目标怪兽是否可以被特殊召唤且场上存在召唤空间
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置连锁操作信息，确定将要特殊召唤的卡
function c52963531.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上有符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52963531.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定特殊召唤的目标为额外卡组中的灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的执行函数，选择并特殊召唤灵摆怪兽
function c52963531.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一只符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c52963531.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选场上的怪兽
function c52963531.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 融合召唤过滤函数，筛选符合条件的融合怪兽
function c52963531.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置融合召唤效果的目标函数，检查是否有可融合召唤的怪兽
function c52963531.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材并筛选在场上的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c52963531.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，则检查其是否能提供满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c52963531.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，指定特殊召唤的目标为额外卡组中的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理融合召唤效果的执行函数，选择并进行融合召唤
function c52963531.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前玩家可用的融合素材并筛选符合条件的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c52963531.filter1,nil,e)
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c52963531.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则获取其提供的融合怪兽组
		sg2=Duel.GetMatchingGroup(c52963531.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用第一种融合方式（直接融合）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从可用融合素材中选择融合所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 进行融合召唤操作
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 从连锁提供的融合素材中选择融合所需的素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
