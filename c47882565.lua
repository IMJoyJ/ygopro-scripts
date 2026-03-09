--RUM－光波昇華
-- 效果：
-- ①：自己·对方的主要阶段，以自己场上1只「光波」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「光波」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽得到以下效果。
-- ●这张卡的攻击力上升自己场上的4星以上的怪兽数量×500。
function c47882565.initial_effect(c)
	-- 创建效果对象，设置为发动时点，需要选择对象，可自由连锁，条件为主要阶段，目标函数为target，处理函数为activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c47882565.condition)
	e1:SetTarget(c47882565.target)
	e1:SetOperation(c47882565.activate)
	c:RegisterEffect(e1)
end
-- 判断当前是否处于主要阶段1或主要阶段2
function c47882565.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时效果才能发动
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数1：检查场上是否有满足条件的光波超量怪兽作为对象
function c47882565.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0xe5)
		-- 检查额外卡组是否存在满足等级要求且可作为超量素材的光波怪兽
		and Duel.IsExistingMatchingCard(c47882565.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 检查该对象是否必须作为超量素材
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数2：检查额外卡组中是否存在满足等级和召唤条件的光波超量怪兽
function c47882565.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xe5) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤且场上存在足够的位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标，选择一个符合条件的光波超量怪兽作为对象，并设置操作信息
function c47882565.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47882565.filter1(chkc,e,tp) end
	-- 判断是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c47882565.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一个符合条件的光波超量怪兽作为对象
	Duel.SelectTarget(tp,c47882565.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤一张来自额外卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理函数：执行效果，包括检查对象、选择目标怪兽并进行特殊召唤
function c47882565.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否满足作为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一张满足等级和召唤条件的光波超量怪兽
	local g=Duel.SelectMatchingCard(tp,c47882565.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象上的叠放卡叠放到新召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象作为新召唤怪兽的素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将符合条件的怪兽从额外卡组特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		-- 为新召唤的怪兽添加攻击力提升效果，数值等于场上4星以上怪兽数量乘以500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c47882565.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		if not sc:IsType(TYPE_EFFECT) then
			-- 若新召唤的怪兽不是效果怪兽，则为其添加效果怪兽类型
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2,true)
		end
		sc:CompleteProcedure()
	end
end
-- 过滤函数：检查场上的光波超量怪兽是否为正面表示且等级大于等于4
function c47882565.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- 计算场上正面表示且等级大于等于4的怪兽数量
function c47882565.atkval(e,c)
	-- 返回场上正面表示且等级大于等于4的怪兽数量乘以500作为攻击力提升值
	return Duel.GetMatchingGroupCount(c47882565.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
