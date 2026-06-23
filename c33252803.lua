--RUM－クイック・カオス
-- 效果：
-- ①：以「混沌No.」怪兽以外的自己场上1只「No.」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶并持有相同「No.」数字的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c33252803.initial_effect(c)
	-- ①：以「混沌No.」怪兽以外的自己场上1只「No.」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c33252803.target)
	e1:SetOperation(c33252803.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：必须是表侧表示、属于「No.」卡组、不属于「混沌No.」卡组、具有No.编号、必须作为超量素材、且在额外卡组存在满足条件的「混沌No.」怪兽。
function c33252803.filter1(c,e,tp)
	-- 获取该怪兽的No.编号。
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and not c:IsSetCard(0x1048) and no
		-- 检查该怪兽是否必须作为超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查在额外卡组是否存在满足条件的「混沌No.」怪兽。
		and Duel.IsExistingMatchingCard(c33252803.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,no)
end
-- 过滤满足条件的「混沌No.」怪兽：必须是对应阶级、属于「混沌No.」卡组、No.编号相同、可以作为超量素材、可以特殊召唤、且场上存在足够的召唤位置。
function c33252803.filter2(c,e,tp,mc,rk,no)
	-- 检查该怪兽是否是对应阶级、属于「混沌No.」卡组、No.编号相同、可以作为超量素材。
	return c:IsRank(rk) and c:IsSetCard(0x1048) and aux.GetXyzNumber(c)==no and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤、且场上存在足够的召唤位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果的目标为满足条件的「No.」超量怪兽。
function c33252803.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c33252803.filter1(chkc,e,tp) end
	-- 检查是否存在满足条件的「No.」超量怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c33252803.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的「No.」超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33252803.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的发动。
function c33252803.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取该怪兽的No.编号。
	local no=aux.GetXyzNumber(tc)
	-- 检查该怪兽是否必须作为超量素材。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not no then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「混沌No.」怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c33252803.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,no)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象怪兽的叠放卡叠放到目标怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象怪兽叠放到目标怪兽上。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将目标怪兽以超量召唤方式特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
