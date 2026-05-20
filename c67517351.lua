--HRUM－ユートピア・フォース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只9阶以下的「希望皇 霍普」超量怪兽为对象才能发动。把1只10阶以上的「霍普」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，10阶以上的「霍普」超量怪兽的效果让超量怪兽特殊召唤的场合，以那之内的1只为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c67517351.initial_effect(c)
	-- ①：以自己场上1只9阶以下的「希望皇 霍普」超量怪兽为对象才能发动。把1只10阶以上的「霍普」超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67517351,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,67517351)
	e1:SetTarget(c67517351.target)
	e1:SetOperation(c67517351.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，10阶以上的「霍普」超量怪兽的效果让超量怪兽特殊召唤的场合，以那之内的1只为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67517351,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,67517352)
	e2:SetCondition(c67517351.matcon)
	e2:SetTarget(c67517351.mattg)
	e2:SetOperation(c67517351.matop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的、9阶以下的「希望皇 霍普」超量怪兽
function c67517351.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x107f) and c:IsType(TYPE_XYZ) and c:IsRankBelow(9)
		-- 检查额外卡组是否存在可重叠召唤的10阶以上「霍普」超量怪兽
		and Duel.IsExistingMatchingCard(c67517351.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中可以重叠在目标怪兽上进行超量召唤的10阶以上「霍普」超量怪兽
function c67517351.filter2(c,e,tp,mc)
	return c:IsRankAbove(10) and c:IsSetCard(0x7f) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以进行超量召唤形式的特殊召唤，且额外怪兽区域有足够的空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①号效果的发动准备，选择自己场上1只9阶以下的「希望皇 霍普」超量怪兽作为对象，并声明特殊召唤的操作信息
function c67517351.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c67517351.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在符合条件的、可作为对象的9阶以下「希望皇 霍普」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c67517351.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的9阶以下「希望皇 霍普」超量怪兽作为对象
	Duel.SelectTarget(tp,c67517351.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①号效果的处理，将额外卡组的10阶以上「霍普」超量怪兽重叠在作为对象的怪兽上进行超量召唤
function c67517351.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否满足必须作为超量素材的限制
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的10阶以上「霍普」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c67517351.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为对象的怪兽持有的超量素材转移给新特殊召唤的怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠作为新特殊召唤怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新怪兽以超量召唤的形式特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤因10阶以上「霍普」超量怪兽的效果而特殊召唤成功的超量怪兽
function c67517351.cfilter(c,e)
	local typ,rk=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RANK)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
		and typ&TYPE_XYZ~=0 and rk>=10 and c:IsSpecialSummonSetCard(0x7f)
end
-- ②号效果的发动条件：检查是否有因10阶以上「霍普」超量怪兽的效果而特殊召唤成功的超量怪兽
function c67517351.matcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c67517351.cfilter,1,nil,e)
end
-- 过滤在本次特殊召唤中出场、且可以作为效果对象的超量怪兽
function c67517351.tgfilter(c,eg)
	return eg:IsContains(c) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ②号效果的发动准备，选择1只特殊召唤的超量怪兽作为对象，并声明墓地卡片离场的操作信息
function c67517351.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c67517351.tgfilter(chkc,eg) end
	-- 检查场上是否存在符合条件的、可作为对象的特殊召唤成功的超量怪兽，且自身可以作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c67517351.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg)
		and e:GetHandler():IsCanOverlay() end
	if eg:GetCount()==1 then
		-- 如果只有1只符合条件的怪兽，则直接将其设为效果对象
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择1只符合条件的特殊召唤成功的超量怪兽作为对象
		Duel.SelectTarget(tp,c67517351.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eg)
	end
	-- 设置墓地卡片离场的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的处理，将墓地的这张卡重叠作为目标怪兽的超量素材
function c67517351.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将墓地的这张卡重叠作为目标怪兽的超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
