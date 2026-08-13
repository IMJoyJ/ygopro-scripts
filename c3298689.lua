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
	-- 将效果2的发动代价设置为：把墓地中的这张卡除外（使用辅助函数aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3298689.mattg)
	e2:SetOperation(c3298689.matop)
	c:RegisterEffect(e2)
end
-- 效果1的发动条件：当前阶段必须为主要阶段1或主要阶段2，才允许发动。
function c3298689.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否处于主要阶段1或主要阶段2，满足任一即可通过条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果1选择对象的筛选条件：自己场上表侧表示、暗属性、阶级大于0且没有超量素材的超量怪兽，并且额外卡组中存在可叠放其上的高1阶暗属性超量怪兽，同时该怪兽满足作为超量素材的限制。
function c3298689.filter1(c,e,tp)
	local rk=c:GetRank()
	return rk>0 and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()==0
		-- 检查额外卡组是否存在至少1只阶级为对象怪兽阶级+1、暗属性、能够以对象怪兽为素材进行超量召唤的额外怪兽。
		and Duel.IsExistingMatchingCard(c3298689.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
		-- 检查对象怪兽是否受到“必须作为超量素材”类效果的限制，确保其可以作为超量素材使用。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组候选怪兽的筛选：阶级等于对象怪兽阶级+1、暗属性、能够以对象怪兽为超量素材特殊召唤，且额外怪兽区有可用空格；同时特殊限制：若候选卡为特定卡（6165656），则对象怪兽必须是No.88。
function c3298689.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and c:IsAttribute(ATTRIBUTE_DARK) and mc:IsCanBeXyzMaterial(c)
		-- 确认候选怪兽能够以超量召唤方式特殊召唤，并且额外怪兽区有空位可供其出场。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果1的发动时点与对象选择：选择自己场上1只符合条件的暗属性超量怪兽作为对象，同时要求发动中的这张卡本身能够作为超量素材叠放。
function c3298689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3298689.filter1(chkc,e,tp) end
	-- 效果发动合法性检查：场上是否存在符合条件的对象怪兽，这张发动卡是否能够作为超量素材，且该卡正处于发动状态下。
	if chk==0 then return Duel.IsExistingTarget(c3298689.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay()
		and (e:IsHasType(EFFECT_TYPE_ACTIVATE) or e:GetHandler():IsLocation(LOCATION_ONFIELD)) end
	-- 向玩家显示选择对象的提示消息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己场上选择1只符合条件的暗属性超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c3298689.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息，标明将进行特殊召唤，特殊召唤的怪兽来源于额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果1处理：获取对象怪兽，验证其仍合法后，从额外卡组选择1只阶级高1阶的暗属性超量怪兽，将对象及其原有超量素材转移给新怪兽，将其以超量召唤方式特殊召唤；若这张发动卡仍在场上，则把这张卡叠放在新怪兽下面作为超量素材。
function c3298689.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果1发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理前再次检查对象怪兽是否仍满足“必须作为超量素材”的限制，若不满足则本次效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家显示选择要特殊召唤怪兽的提示消息，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的暗属性超量怪兽（阶级为对象怪兽阶级+1）。
	local g=Duel.SelectMatchingCard(tp,c3298689.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的全部超量素材转移给新选择的超量怪兽。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象怪兽本身叠放在新超量怪兽下方，作为其超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以超量召唤方式、表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 若这张发动卡仍处于场上（与效果相关），则将其叠放在新超量怪兽下方作为超量素材。
			Duel.Overlay(sc,Group.FromCards(c))
		end
	end
end
-- 效果2选择对象的筛选条件：自己场上表侧表示、暗属性且为超量怪兽。
function c3298689.xyzfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
-- 效果2选择手牌素材的筛选条件：手牌中1只卡名含有「幻影骑士团」字段的怪兽，并且该怪兽可以作为超量素材。
function c3298689.matfilter(c)
	return c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 效果2的发动条件与对象选择：选择自己场上1只表侧表示暗属性超量怪兽为对象，且手牌存在「幻影骑士团」怪兽可以作为超量素材。
function c3298689.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3298689.xyzfilter(chkc) end
	-- 效果2发动合法性检查：场上是否存在符合条件的暗属性超量怪兽对象。
	if chk==0 then return Duel.IsExistingTarget(c3298689.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查手牌是否存在1只符合条件的「幻影骑士团」怪兽。
		and Duel.IsExistingMatchingCard(c3298689.matfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择对象卡片的提示消息，提示文字为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只符合条件的暗属性超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c3298689.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果2处理：若对象怪兽仍然合法，则从手牌选择1只「幻影骑士团」怪兽叠放在对象怪兽下面作为超量素材。
function c3298689.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果2选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 向玩家显示选择要作为超量素材的卡的提示消息，提示文字为“请选择要作为超量素材的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手牌选择1只符合条件的「幻影骑士团」怪兽。
		local g=Duel.SelectMatchingCard(tp,c3298689.matfilter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「幻影骑士团」怪兽叠放在对象怪兽下面作为超量素材。
			Duel.Overlay(tc,g)
		end
	end
end
