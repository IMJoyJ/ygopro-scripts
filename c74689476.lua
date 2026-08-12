--結晶の魔女サンドリヨン
-- 效果：
-- 属性不同的魔法师族4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「大贤者」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「大贤者」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡装备中的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c74689476.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：需要2只4星的魔法师族怪兽，且它们的属性必须不同
	aux.AddXyzProcedureLevelFree(c,c74689476.mfilter,c74689476.xyzcheck,2,2)
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「大贤者」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「大贤者」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74689476,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,74689476)
	e1:SetCost(c74689476.spcost)
	e1:SetTarget(c74689476.sptg)
	e1:SetOperation(c74689476.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡装备中的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74689476,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,74689477)
	e2:SetCondition(c74689476.discon)
	e2:SetTarget(c74689476.distg)
	e2:SetOperation(c74689476.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：4星的魔法师族怪兽
function c74689476.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsRace(RACE_SPELLCASTER)
end
-- 额外检查：作为XYZ素材的怪兽属性必须各不相同
function c74689476.xyzcheck(g)
	return g:GetClassCount(Card.GetAttribute)==#g
end
-- 效果①的Cost：取除这张卡的1个超量素材
function c74689476.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡组中可以特殊召唤的「大贤者」怪兽
function c74689476.spfilter(c,e,tp)
	return c:IsSetCard(0x150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target：检查怪兽区域空位和卡组中是否存在可特殊召唤的「大贤者」怪兽，并设置特殊召唤的操作信息
function c74689476.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可以特殊召唤的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c74689476.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation：从卡组特殊召唤1只「大贤者」怪兽，并适用“直到回合结束时自己不是「大贤者」怪兽不能从额外卡组特殊召唤”的限制
function c74689476.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「大贤者」怪兽
	local g=Duel.SelectMatchingCard(tp,c74689476.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「大贤者」怪兽不能从额外卡组特殊召唤。 / ②：这张卡装备中的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c74689476.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤「大贤者」以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果：限制玩家只能从额外卡组特殊召唤「大贤者」怪兽
function c74689476.splimit(e,c)
	return not c:IsSetCard(0x150) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：这张卡处于装备状态
function c74689476.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 效果②的Target：选择对方场上1只未被无效的效果怪兽作为对象，并设置无效的操作信息
function c74689476.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查重构对象：必须是对方场上未被无效的效果怪兽
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只未被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只未被无效的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的Operation：使作为对象的怪兽的效果直到回合结束时无效
function c74689476.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使和该怪兽相关的连锁都无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
