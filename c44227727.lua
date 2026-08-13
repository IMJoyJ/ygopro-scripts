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
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己场上1只「海造贼」怪兽为对象才能发动。那只自己怪兽从卡组把1张「海造贼-象征」装备或从卡组把1只「海造贼」怪兽当作装备卡使用来装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44227727,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44227727)
	-- 为②效果设置发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44227727.eqtg)
	e2:SetOperation(c44227727.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数：排除不受当前效果影响的怪兽，作为融合素材候选的筛选条件。
function c44227727.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：检查额外卡组的怪兽是否为恶魔族融合怪兽、能否特殊召唤，且能用给定的素材进行融合召唤。
function c44227727.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动条件判定：检查额外卡组是否存在能用当前融合素材（或连锁素材）融合召唤的恶魔族融合怪兽；满足时登记特殊召唤操作信息。
function c44227727.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用于融合召唤的素材组（手卡·场上的怪兽及额外融合素材效果适用的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在满足filter2条件的恶魔族融合怪兽（使用通常融合素材）。
		local res=Duel.IsExistingMatchingCard(c44227727.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（若有），用于后续替代/补充融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若通常素材不可用，则检查使用连锁素材提供的素材能否融合召唤恶魔族融合怪兽。
				res=Duel.IsExistingMatchingCard(c44227727.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：将进行1只从额外卡组的特殊召唤（融合召唤），供相关卡牌效果响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的融合召唤处理：选择要融合召唤的恶魔族融合怪兽，选择融合素材并送去墓地，然后特殊召唤；若使用连锁素材则按连锁素材效果处理。
function c44227727.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得通常融合素材，并过滤掉免疫此效果的卡，确保素材合法可用。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c44227727.filter1,nil,e)
	-- 获取所有能用通常融合素材融合召唤的恶魔族融合怪兽的集合。
	local sg1=Duel.GetMatchingGroup(c44227727.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（若有），用于可能替代素材来源。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取所有能用连锁素材效果提供的素材融合召唤的恶魔族融合怪兽的集合。
		sg2=Duel.GetMatchingGroup(c44227727.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家显示“请选择要特殊召唤的卡”的提示，用于选择融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选的融合怪兽是否可用通常素材融合召唤，且玩家未选择使用连锁素材；是则走通常融合流程，否则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常融合素材中选择一组满足该融合怪兽召唤条件的素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，原因标记为效果、融合素材与融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果的处理链，使素材送墓与特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若使用连锁素材效果，则让玩家从连锁素材提供的一组素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2,SUMMON_TYPE_FUSION)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：选出卡组中可装备给对象的卡——「海造贼」怪兽（当作装备卡使用）或「海造贼-象征」；同时要求不是禁止卡、场上无同名卡且能放置在魔陷区。
function c44227727.eqfilter(c,ec,tp)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x13f) or c:IsCode(80621422) and c:CheckEquipTarget(ec))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤函数：选择我方场上表侧表示的「海造贼」怪兽作为对象，且卡组中存在至少一张可以装备给它的候选装备卡。
function c44227727.cfilter(c,tp)
	-- 对象怪兽必须表侧表示且属于「海造贼」字段，并且卡组中有符合条件的可装备卡。
	return c:IsFaceup() and c:IsSetCard(0x13f) and Duel.IsExistingMatchingCard(c44227727.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 效果②的发动条件检查与对象选择：场上存在符合条件的「海造贼」怪兽且魔陷区有空位；选择对象后登记从卡组装备的操作信息。
function c44227727.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44227727.cfilter(chkc,tp) end
	-- 发动时检查场上是否存在满足条件的对象怪兽（表侧「海造贼」且卡组有可装备卡）。
	if chk==0 then return Duel.IsExistingTarget(c44227727.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 同时确认自己的魔法与陷阱区域有空位，用于放置装备卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 显示“请选择效果的对象”的提示，引导玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的表侧「海造贼」怪兽作为效果对象。
	Duel.SelectTarget(tp,c44227727.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记操作信息：将从卡组取1张装备卡进行装备，供后续效果判断。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
-- 效果②的装备处理：取得对象，若对象仍合法且魔陷区有空位，则从卡组选择1张装备卡（「海造贼-象征」或「海造贼」怪兽）装备给对象，并为该装备卡添加只能装备给此对象的限制。
function c44227727.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动效果时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时若魔法与陷阱区域没有空位，则效果处理失败，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 显示“请选择要装备的卡”的提示，引导玩家从卡组选择装备卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1张满足eqfilter条件的卡作为装备候选。
		local g=Duel.SelectMatchingCard(tp,c44227727.eqfilter,tp,LOCATION_DECK,0,1,1,nil,tc,tp)
		local sc=g:GetFirst()
		if not sc then return end
		-- 将选出的卡作为装备卡装备给对象怪兽；若装备失败则中止处理。
		if not Duel.Equip(tp,sc,tc) then return end
		-- 那只自己怪兽从卡组把1张「海造贼-象征」装备或从卡组把1只「海造贼」怪兽当作装备卡使用来装备。
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
-- 装备限制函数：判断装备卡是否只能装备给原装备对象（通过标签记录的目标怪兽比较）。
function c44227727.eqlimit(e,c)
	return c==e:GetLabelObject()
end
