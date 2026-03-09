--RUM－ヌメロン・フォース
-- 效果：
-- ①：以自己场上1只超量怪兽为对象才能发动。和那只自己怪兽相同种族而阶级高1阶的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。那之后，这个效果特殊召唤的怪兽以外的场上的全部表侧表示的卡的效果无效化。
function c48333324.initial_effect(c)
	-- 创建效果，设置为发动时点，可以取对象，目标为己方场上1只超量怪兽，特殊召唤类别为CATEGORY_SPECIAL_SUMMON
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c48333324.target)
	e1:SetOperation(c48333324.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查己方场上是否存在满足条件的超量怪兽（表侧表示、类型为超量、有可作为超量素材的卡、且存在满足条件的「混沌No.」怪兽）
function c48333324.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查是否存在满足filter2条件的额外卡组中的「混沌No.」怪兽
		and Duel.IsExistingMatchingCard(c48333324.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,c:GetRace(),c:GetCode())
		-- 检查目标怪兽是否满足必须作为超量素材的条件
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数，检查额外卡组中是否存在满足阶级、种族、卡包、可作为超量素材、可特殊召唤且有足够召唤位置的「混沌No.」怪兽
function c48333324.filter2(c,e,tp,mc,rk,rc,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤并判断是否有足够的召唤位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标为己方场上1只满足filter1条件的怪兽，选择对象后设置操作信息为特殊召唤类别
function c48333324.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c48333324.filter1(chkc,e,tp) end
	-- 检查是否存在满足filter1条件的己方场上怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c48333324.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足filter1条件的己方场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,c48333324.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤1张额外卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果发动，获取目标怪兽并进行有效性检查，然后选择要特殊召唤的「混沌No.」怪兽
function c48333324.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 再次确认目标怪兽是否满足必须作为超量素材的条件
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足filter2条件的「混沌No.」怪兽
	local g=Duel.SelectMatchingCard(tp,c48333324.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,tc:GetRace(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放卡叠放到要特殊召唤的怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到要特殊召唤的怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 以超量召唤方式将选定的怪兽从额外卡组特殊召唤到己方场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		-- 获取场上所有表侧表示的卡
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,sc)
		if c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			g1:RemoveCard(c)
		end
		if g1:GetCount()>0 then
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
		end
		-- 筛选出可以被无效化的场上卡
		local ng=g1:Filter(aux.NegateAnyFilter,nil)
		local nc=ng:GetFirst()
		while nc do
			-- 创建一个永续效果，使目标卡的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			nc:RegisterEffect(e2)
			if nc:IsType(TYPE_TRAPMONSTER) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				nc:RegisterEffect(e3)
			end
			nc=ng:GetNext()
		end
	end
end
