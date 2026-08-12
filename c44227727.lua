--海造賊－進水式
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把恶魔族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「海造贼」怪兽为对象才能发动。那只自己怪兽从卡组把1张「海造贼-象征」装备或从卡组把1只「海造贼」怪兽当作装备卡使用来装备。
function c44227727.initial_effect(c)
	-- ①：从自己的手卡·场上把恶魔族融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44227727,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44227727.target)
	e1:SetOperation(c44227727.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「海造贼」怪兽为对象才能发动。那只自己怪兽从卡组把1张「海造贼-象征」装备或从卡组把1只「海造贼」怪兽当作装备卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44227727,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44227727)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44227727.eqtg)
	e2:SetOperation(c44227727.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选融合素材中不处于效果免疫状态的怪兽
function c44227727.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足融合条件的恶魔族融合怪兽
function c44227727.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否能从额外卡组特殊召唤融合怪兽
function c44227727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c44227727.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c44227727.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，表示将要特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理融合召唤效果，选择并特殊召唤融合怪兽
function c44227727.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 过滤融合素材，排除处于效果免疫状态的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44227727.filter1,nil,e)
	-- 获取满足融合条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c44227727.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c44227727.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择连锁融合所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数，用于筛选可装备的「海造贼」怪兽或「海造贼-象征」
function c44227727.eqfilter(c,ec,tp)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13f) or c:IsCode(80621422) and c:CheckEquipTarget(ec))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤函数，用于筛选可装备装备卡的「海造贼」怪兽
function c44227727.cfilter(c,tp)
	-- 判断目标怪兽是否为「海造贼」怪兽且卡组存在可装备的装备卡
	return c:IsFaceup() and c:IsSetCard(0x13f) and Duel.IsExistingMatchingCard(c44227727.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 判断是否能选择目标怪兽
function c44227727.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44227727.cfilter(chkc,tp) end
	-- 检查是否存在满足条件的「海造贼」怪兽
	if chk==0 then return Duel.IsExistingTarget(c44227727.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查场上是否有足够的装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择装备对象
	Duel.SelectTarget(tp,c44227727.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁操作信息，表示将要装备装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
-- 处理装备效果，选择并装备装备卡
function c44227727.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查场上是否有足够的装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择可装备的装备卡
		local g=Duel.SelectMatchingCard(tp,c44227727.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		local sc=g:GetFirst()
		if not sc then return end
		-- 执行装备操作
		if not Duel.Equip(tp,sc,tc) then return end
		-- 设置装备限制效果，确保装备卡只能装备给指定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(c44227727.eqlimit)
		sc:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保装备卡只能装备给指定怪兽
function c44227727.eqlimit(e,c)
	return c==e:GetLabelObject()
end
