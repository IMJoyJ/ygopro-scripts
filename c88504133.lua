--RUM－ファントム・フォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，从自己墓地把暗属性怪兽任意数量除外，以自己场上1只暗属性超量怪兽为对象才能发动。比作为对象的自己怪兽阶级要高除外数量数值的「幻影骑士团」、「急袭猛禽」、「超量龙」超量怪兽之内任意1只在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
function c88504133.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，从自己墓地把暗属性怪兽任意数量除外，以自己场上1只暗属性超量怪兽为对象才能发动。比作为对象的自己怪兽阶级要高除外数量数值的「幻影骑士团」、「急袭猛禽」、「超量龙」超量怪兽之内任意1只在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88504133,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88504133+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c88504133.condition)
	e1:SetCost(c88504133.cost)
	e1:SetTarget(c88504133.target)
	e1:SetOperation(c88504133.activate)
	c:RegisterEffect(e1)
end
-- 判定当前阶段是否为自己或对方的主要阶段。
function c88504133.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤墓地中可以作为cost除外的暗属性怪兽。
function c88504133.cgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 过滤额外卡组中满足升阶特殊召唤条件的「幻影骑士团」、「急袭猛禽」或「超量龙」超量怪兽。
function c88504133.cefilter(c,tc,ct,e,tp)
	if not c:IsType(TYPE_XYZ) then return false end
	local r=c:GetRank()-tc:GetRank()
	return c:IsSetCard(0xba,0x10db,0x2073)
		and tc:IsCanBeXyzMaterial(c) and r>0 and ct>=r
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查在将作为素材的怪兽送去墓地或叠放后，额外卡组怪兽是否有可用的特殊召唤区域。
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 过滤场上可以作为此卡效果对象的表侧表示暗属性超量怪兽。
function c88504133.cfilter(c,e,tp)
	-- 获取自己墓地中满足除外条件的暗属性怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c88504133.cgfilter,tp,LOCATION_GRAVE,0,nil)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
		and c:IsCanBeEffectTarget(e)
		-- 检查额外卡组是否存在至少1只满足升阶召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c88504133.cefilter,tp,LOCATION_EXTRA,0,1,nil,c,ct,e,tp)
end
-- 效果发动成本（Cost）处理函数，设置标签以标记需要进行除外数量的计算。
function c88504133.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤额外卡组中阶级差正好等于已宣告除外数量的特定系列超量怪兽。
function c88504133.tgefilter(c,tc,e,tp,rank)
	if not c:IsType(TYPE_XYZ) then return false end
	local r=c:GetRank()-tc:GetRank()
	return c:IsSetCard(0xba,0x10db,0x2073)
		and tc:IsCanBeXyzMaterial(c) and r==rank
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查在将作为素材的怪兽送去墓地或叠放后，额外卡组怪兽是否有可用的特殊召唤区域。
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end
-- 过滤场上可以作为升阶素材的暗属性超量怪兽。
function c88504133.tgfilter(c,e,tp,rank)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查该怪兽是否满足必须作为超量素材的规则限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在阶级差正好等于除外数量的特定系列超量怪兽。
		and Duel.IsExistingMatchingCard(c88504133.tgefilter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp,rank)
end
-- 效果发动时的目标选择（Target）处理函数，计算可宣告的除外数量并让玩家选择除外数量、除外卡片以及选择场上的超量怪兽作为对象。
function c88504133.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c88504133.cfilter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在可以作为此卡效果对象的暗属性超量怪兽。
		return Duel.IsExistingTarget(c88504133.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	local avail={}
	local availbool={}
	-- 获取自己墓地中可作为Cost除外的暗属性怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c88504133.cgfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取场上所有满足条件的暗属性超量怪兽。
	local gfield=Duel.GetMatchingGroup(c88504133.cfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	-- 遍历场上所有满足条件的暗属性超量怪兽。
	for tc in aux.Next(gfield) do
		-- 获取额外卡组中对于当前场上怪兽而言，阶级差在可除外数量范围内的所有合法超量怪兽。
		local gextra=Duel.GetMatchingGroup(c88504133.cefilter,tp,LOCATION_EXTRA,0,nil,tc,ct,e,tp)
		-- 遍历这些合法的额外卡组超量怪兽。
		for ex in aux.Next(gextra) do
			local r=ex:GetRank()-tc:GetRank()
			if not availbool[r] then
				availbool[r]=true
				table.insert(avail,r)
			end
		end
	end
	-- 提示玩家选择要除外的怪兽数量。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88504133,1))  --"请选择要除外的怪兽的数量"
	-- 让玩家宣告一个合法的除外数量。
	local num=Duel.AnnounceNumber(tp,table.unpack(avail))
	e:SetLabel(num)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择与宣告数量相同的暗属性怪兽。
	local cost=Duel.SelectMatchingCard(tp,c88504133.cgfilter,tp,LOCATION_GRAVE,0,num,num,nil)
	-- 将选择的墓地怪兽表侧表示除外作为发动的Cost。
	Duel.Remove(cost,POS_FACEUP,REASON_COST)
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只满足条件的暗属性超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c88504133.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,num)
	-- 设置连锁的操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Operation）函数，将额外卡组的特定超量怪兽重叠在对象怪兽上进行超量召唤，并添加额外卡组特殊召唤限制。
function c88504133.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足必须作为超量素材的规则限制，且在场上表侧表示存在。
	if aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and tc:IsFaceup()
		and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只阶级比对象怪兽高除外数量数值的特定系列超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c88504133.tgefilter,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp,e:GetLabel())
		local sc=g:GetFirst()
		if sc then
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将作为素材的怪兽原本持有的超量素材重叠到新召唤的超量怪兽下面。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(tc))
			-- 将作为对象的怪兽重叠到新召唤的超量怪兽下面作为超量素材。
			Duel.Overlay(sc,Group.FromCards(tc))
			-- 将新超量怪兽以超量召唤的形式在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c88504133.splimit)
	-- 注册该玩家限制效果，使其在全局生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数，阻止玩家从额外卡组特殊召唤超量怪兽以外的怪兽。
function c88504133.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
