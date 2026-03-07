--シャイニング・ドロー
-- 效果：
-- ①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1，可以以自己场上1只「希望皇 霍普」超量怪兽为对象，从以下效果选择1个发动。
-- ●从卡组·额外卡组选卡名不同的「异热同心武器」怪兽任意数量当作装备卡使用给作为对象的怪兽装备。
-- ●和作为对象的自己怪兽卡名不同的1只「希望皇 霍普」超量怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c35906693.initial_effect(c)
	-- 效果原文：①：自己抽卡阶段通过把通常抽卡的这张卡持续公开，那个回合的主要阶段1，可以以自己场上1只「希望皇 霍普」超量怪兽为对象，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c35906693.regcon)
	e1:SetOperation(c35906693.regop)
	c:RegisterEffect(e1)
	-- 效果原文：●从卡组·额外卡组选卡名不同的「异热同心武器」怪兽任意数量当作装备卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35906693,1))  --"装备"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c35906693.condition)
	e2:SetCost(c35906693.cost)
	e2:SetTarget(c35906693.eqtg)
	e2:SetOperation(c35906693.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(35906693,2))  --"超量召唤"
	e3:SetTarget(c35906693.sptg)
	e3:SetOperation(c35906693.spop)
	c:RegisterEffect(e3)
end
-- 规则层面：判断是否满足效果发动条件，即玩家未发动过此效果、当前处于抽卡阶段、此卡因规则而被抽卡
function c35906693.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：判断是否满足效果发动条件，即玩家未发动过此效果、当前处于抽卡阶段、此卡因规则而被抽卡
	return Duel.GetFlagEffect(tp,35906693)==0 and Duel.GetCurrentPhase()==PHASE_DRAW and c:IsReason(REASON_RULE)
end
-- 规则层面：询问玩家是否要持续公开此卡，若选择公开则设置公开效果和标志
function c35906693.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：询问玩家是否要持续公开此卡
	if Duel.SelectYesNo(tp,aux.Stringid(35906693,0)) then  --"是否要持续公开「闪光抽卡」？"
		-- 效果原文：●和作为对象的自己怪兽卡名不同的1只「希望皇 霍普」超量怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(35906693,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1,EFFECT_FLAG_CLIENT_HINT,1,0,66)
	end
end
-- 规则层面：判断是否处于主要阶段1
function c35906693.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否处于主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 规则层面：判断是否已通过抽卡阶段公开此卡
function c35906693.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(35906693)~=0 end
end
-- 规则层面：过滤目标怪兽，必须为表侧表示、属于希望皇系列、且为超量怪兽
function c35906693.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ)
end
-- 规则层面：过滤装备卡，必须为异热同心武器系列、为怪兽类型、在场上未重复、且未被禁止
function c35906693.eqfilter(c,tp)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 规则层面：设置装备效果的目标选择和条件检查
function c35906693.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35906693.tgfilter(chkc) end
	-- 规则层面：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c35906693.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 规则层面：检查场上是否有足够的装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面：检查卡组或额外卡组是否存在满足条件的装备卡
		and Duel.IsExistingMatchingCard(c35906693.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	-- 规则层面：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面：选择目标怪兽
	Duel.SelectTarget(tp,c35906693.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 规则层面：装备卡的处理流程
function c35906693.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取玩家场上装备区域的可用数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local c=e:GetHandler()
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if ft<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 规则层面：提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面：获取满足条件的装备卡组
	local g=Duel.GetMatchingGroup(c35906693.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,tp)
	-- 规则层面：从装备卡组中选择卡名不同的卡组
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if not sg then return end
	local ec=sg:GetFirst()
	while ec do
		-- 规则层面：将装备卡装备给目标怪兽
		Duel.Equip(tp,ec,tc,true,true)
		-- 效果原文：从卡组·额外卡组选卡名不同的「异热同心武器」怪兽任意数量当作装备卡使用给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c35906693.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		ec=sg:GetNext()
	end
	-- 规则层面：完成装备过程
	Duel.EquipComplete()
end
-- 效果原文：和作为对象的自己怪兽卡名不同的1只「希望皇 霍普」超量怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c35906693.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 规则层面：过滤目标怪兽，必须为表侧表示、属于希望皇系列、且为超量怪兽，并且能作为超量召唤的素材
function c35906693.filter1(c,e,tp)
	return c35906693.tgfilter(c)
		-- 规则层面：检查是否存在满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(c35906693.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 规则层面：检查目标怪兽是否满足超量召唤的素材要求
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 规则层面：过滤超量怪兽，必须为希望皇系列、为超量怪兽、卡名不同、能作为目标怪兽的素材、可特殊召唤、且有足够召唤区域
function c35906693.filter2(c,e,tp,mc)
	return c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ) and not c:IsCode(mc:GetCode()) and mc:IsCanBeXyzMaterial(c)
		-- 规则层面：检查超量怪兽是否可特殊召唤、且有足够召唤区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 规则层面：设置超量召唤效果的目标选择和条件检查
function c35906693.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35906693.filter1(chkc,e,tp) end
	-- 规则层面：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c35906693.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 规则层面：提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 规则层面：选择目标怪兽
	Duel.SelectTarget(tp,c35906693.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 规则层面：设置操作信息，表示将要特殊召唤超量怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 规则层面：超量召唤的处理流程
function c35906693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面：检查目标怪兽是否满足超量召唤的素材要求
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 规则层面：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：选择满足条件的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c35906693.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 规则层面：将目标怪兽的叠放卡叠放到特殊召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 规则层面：将目标怪兽叠放到特殊召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 规则层面：将特殊召唤的超量怪兽以超量召唤方式特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
