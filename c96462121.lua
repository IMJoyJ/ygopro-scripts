--超接地展開
-- 效果：
-- ①：自己场上的机械族超量怪兽不会成为对方的效果的对象。
-- ②：1回合1次，以自己场上1只「无限起动」超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶的1只机械族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤。
function c96462121.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的机械族超量怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c96462121.immtg)
	-- 设置不能成为对象的效果来源为对方玩家（即不会成为对方的效果的对象）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只「无限起动」超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶的1只机械族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96462121,0))  --"升阶"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c96462121.target)
	e3:SetOperation(c96462121.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的机械族超量怪兽。
function c96462121.immtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 过滤场上可以作为此效果对象的、表侧表示的「无限起动」超量怪兽。
function c96462121.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x127)
		-- 检查该怪兽是否满足必须作为超量素材的限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件的、比该怪兽阶级高2阶的机械族超量怪兽。
		and Duel.IsExistingMatchingCard(c96462121.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank()+2,c)
end
-- 过滤额外卡组中可以重叠特殊召唤的机械族超量怪兽。
function c96462121.spfilter(c,e,tp,rank,mc)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ) and c:IsRank(rank) and mc:IsCanBeXyzMaterial(c,tp)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，并检查在将素材怪兽重叠时额外怪兽区域是否有可用位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动准备，进行合法性检查、选择对象并设置特殊召唤的操作信息。
function c96462121.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c96462121.tgfilter(chkc,e,tp) end
	-- 发动检查：自己场上是否存在可以作为此效果对象的「无限起动」超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c96462121.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为效果对象的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「无限起动」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c96462121.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：将额外卡组高2阶的机械族超量怪兽重叠在对象怪兽上当作超量召唤特殊召唤，并适用特殊召唤限制。
function c96462121.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象（即选中的「无限起动」超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup()
		-- 检查对象怪兽是否仍满足必须作为超量素材的限制，且不免疫此卡的效果。
		and aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只比对象怪兽阶级高2阶的机械族超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c96462121.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank()+2,tc)
		local sc=g:GetFirst()
		if sc then
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 将原超量怪兽持有的超量素材转移给新特殊召唤的超量怪兽。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(tc))
			-- 将作为对象的原超量怪兽重叠作为新超量怪兽的超量素材。
			Duel.Overlay(sc,Group.FromCards(tc))
			-- 将新超量怪兽以表侧表示特殊召唤（当作超量召唤）。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96462121.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤机械族·地属性怪兽。
function c96462121.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end
