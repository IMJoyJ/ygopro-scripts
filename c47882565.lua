--RUM－光波昇華
-- 效果：
-- ①：自己·对方的主要阶段，以自己场上1只「光波」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「光波」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽得到以下效果。
-- ●这张卡的攻击力上升自己场上的4星以上的怪兽数量×500。
function c47882565.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只「光波」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只「光波」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽得到以下效果。●这张卡的攻击力上升自己场上的4星以上的怪兽数量×500。
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
-- 发动条件判定：当当前阶段为主要阶段1或主要阶段2时，该魔法卡可在自己·对方的主要阶段发动。
function c47882565.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，以符合“自己·对方的主要阶段才能发动”的发动时机要求。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 对象怪兽的筛选：必须是表侧表示、阶级大于0、卡名属于「光波」字段的超量怪兽，且额外卡组存在比其高一阶的可特殊召唤「光波」超量怪兽，并且该怪兽没有被“必须用作超量素材”的效果限制。
function c47882565.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsSetCard(0xe5)
		-- 检查额外卡组中是否存在1只满足 filter2 的「光波」超量怪兽，即阶级为对象阶级+1、可作为对象的超量素材、能够以超量召唤方式从额外卡组特殊召唤且有可用区域。
		and Duel.IsExistingMatchingCard(c47882565.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 确认对象怪兽没有受到 EFFECT_MUST_BE_XMATERIAL（必须作为超量素材）等效果的限制，确保其可以作为超量素材被用于重叠召唤。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组候选怪兽的筛选：阶级等于指定的阶级（对象阶级+1）、属于「光波」字段、对象怪兽可作为其超量素材、自身可以超量召唤特殊召唤，且对象离场后有足够的额外卡组怪兽出场区域。
function c47882565.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xe5) and mc:IsCanBeXyzMaterial(c)
		-- 确认候选怪兽能够以超量召唤方式从额外卡组特殊召唤，并且从额外卡组出场时有可用的怪兽区域（考虑对象离场后腾出的位置）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 发动目标处理：先校验合法性，若为连锁确认则验证所选卡；若为发动检查则确认存在可对象；随后提示并选择1只自己场上的「光波」超量怪兽作为对象，并登记从额外卡组进行1次特殊召唤的操作信息。
function c47882565.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47882565.filter1(chkc,e,tp) end
	-- chk==0 时进行发动合法性检查，确认自己场上是否存在至少1只符合 filter1 的「光波」超量怪兽可以选择。
	if chk==0 then return Duel.IsExistingTarget(c47882565.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 弹出选择卡片的提示，提示文字为“请选择效果的对象”，用于引导玩家选择超量怪兽对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己怪兽区选择1只符合条件的「光波」超量怪兽作为效果对象，并与当前连锁建立对象关联。
	Duel.SelectTarget(tp,c47882565.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：本连锁将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），预计从额外卡组特殊召唤1只怪兽；因处理时才确定具体卡牌，对象设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取得对象并再次校验合法性；从额外卡组选择比对象阶级高1阶的「光波」超量怪兽，将对象及其原有叠放素材全部叠放至新卡下，以超量召唤方式特殊召唤；随后给该怪兽赋予攻击力上升效果（并补上效果怪兽类型），最后完成超量召唤手续。
function c47882565.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽，即自己场上的「光波」超量怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次确认对象仍可作为超量素材；若其受到“必须作为超量素材”等效果而无法作为素材，则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 弹出选择卡片的提示，提示文字为“请选择要特殊召唤的卡”，用于选择额外卡组中要特殊召唤的「光波」超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的超量怪兽：阶级为对象阶级+1、属于「光波」字段、对象可作为其超量素材、且能以超量召唤方式特殊召唤并出场。
	local g=Duel.SelectMatchingCard(tp,c47882565.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象持有的超量素材整组叠放到新超量怪兽下方，使素材完整继承。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的超量怪兽本身叠放到新超量怪兽下方，完成“在作为对象的怪兽上面重叠”的超量召唤素材处理。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤（SUMMON_TYPE_XYZ）的方式将新超量怪兽表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		-- ●这张卡的攻击力上升自己场上的4星以上的怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c47882565.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
		if not sc:IsType(TYPE_EFFECT) then
			-- 这个效果特殊召唤的怪兽得到以下效果。●这张卡的攻击力上升自己场上的4星以上的怪兽数量×500。
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
-- 攻击力上升的计数怪兽筛选：场上的表侧表示怪兽，且等级为4星以上。
function c47882565.atkfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- 计算攻击力上升值：统计该怪兽控制者自己场上表侧表示且4星以上的怪兽数量，每1只上升500攻击力。
function c47882565.atkval(e,c)
	-- 返回自己场上表侧表示4星以上怪兽数量×500的数值，作为该怪兽的攻击力上升量。
	return Duel.GetMatchingGroupCount(c47882565.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*500
end
