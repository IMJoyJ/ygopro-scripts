--RUM－幻影騎士団ラウンチ
-- 效果：
-- ①：自己·对方的主要阶段，以自己场上1只没有超量素材的暗属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只暗属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只暗属性超量怪兽为对象才能发动。把手卡1只「幻影骑士团」怪兽在那只怪兽下面重叠作为超量素材。
function c3298689.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只没有超量素材的暗属性超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶的1只暗属性超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c3298689.condition)
	e1:SetTarget(c3298689.target)
	e1:SetOperation(c3298689.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只暗属性超量怪兽为对象才能发动。把手卡1只「幻影骑士团」怪兽在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3298689,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3298689.mattg)
	e2:SetOperation(c3298689.matop)
	c:RegisterEffect(e2)
end
-- 效果发动时点：自己主要阶段
function c3298689.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤满足条件的怪兽：阶级大于0、表侧表示、暗属性、没有超量素材、场上存在比该怪兽阶级高1阶的暗属性超量怪兽、该怪兽必须能成为超量素材
function c3298689.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()==0
		-- 场上存在比该怪兽阶级高1阶的暗属性超量怪兽
		and Duel.IsExistingMatchingCard(c3298689.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
		-- 该怪兽必须能成为超量素材
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤满足条件的额外卡组怪兽：阶级等于目标怪兽阶级+1、暗属性、能成为目标怪兽的超量素材、能特殊召唤、场上空位足够
function c3298689.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and c:IsAttribute(ATTRIBUTE_DARK) and mc:IsCanBeXyzMaterial(c)
		-- 能特殊召唤且场上空位足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标：选择自己场上满足条件的1只怪兽
function c3298689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3298689.filter1(chkc,e,tp) end
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c3298689.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay()
		and (e:IsHasType(EFFECT_TYPE_ACTIVATE) or e:GetHandler():IsLocation(LOCATION_ONFIELD)) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c3298689.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤1只额外卡组怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：特殊召唤额外卡组怪兽并叠放素材
function c3298689.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否能成为超量素材
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c3298689.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽的叠放卡叠放到目标怪兽上
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽叠放到目标怪兽上
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将此卡叠放到目标怪兽上
			Duel.Overlay(sc,Group.FromCards(c))
		end
	end
end
-- 过滤满足条件的暗属性超量怪兽
function c3298689.xyzfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
-- 过滤满足条件的「幻影骑士团」怪兽
function c3298689.matfilter(c)
	return c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 设置效果目标：选择自己场上1只满足条件的暗属性超量怪兽
function c3298689.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3298689.xyzfilter(chkc) end
	-- 检查是否有满足条件的暗属性超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c3298689.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 手牌中存在满足条件的「幻影骑士团」怪兽
		and Duel.IsExistingMatchingCard(c3298689.matfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的暗属性超量怪兽作为效果对象
	Duel.SelectTarget(tp,c3298689.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将手牌中的「幻影骑士团」怪兽叠放到对象怪兽上
function c3298689.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手牌中选择满足条件的1只「幻影骑士团」怪兽
		local g=Duel.SelectMatchingCard(tp,c3298689.matfilter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽叠放到对象怪兽上
			Duel.Overlay(tc,g)
		end
	end
end
