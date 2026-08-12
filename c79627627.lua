--半纏鳥官－コンバード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的战斗阶段，以场上1只里侧表示怪兽为对象才能发动。那只怪兽送去墓地，这张卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。除「半缠鸟官-转变鸟」外的1只5星以上的反转怪兽从卡组里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ②：这张卡反转的场合才能发动。除「半缠鸟官-转变鸟」外的1只5星以上的反转怪兽从卡组里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在的场合，自己·对方的战斗阶段，以场上1只里侧表示怪兽为对象才能发动。那只怪兽送去墓地，这张卡里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 反转效果的发动准备与合法性检测。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以使用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的、可以里侧守备表示特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中除「半缠鸟官-转变鸟」以外、等级5以上且可以里侧守备表示特殊召唤的反转怪兽。
function s.filter(c,e,tp)
	return not c:IsCode(id) and c:IsLevelAbove(5) and c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 反转效果的实际处理：从卡组选择1只满足条件的怪兽里侧守备表示特殊召唤，并给对方确认。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中所有满足过滤条件的怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认里侧特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 限制该效果只能在自己或对方的战斗阶段发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤场上的里侧表示怪兽，且该怪兽离场后必须能空出怪兽区域。
function s.tfilter(c,tp)
	-- 检查怪兽是否为里侧表示，且该怪兽离场后自己场上是否有可用的怪兽区域。
	return c:IsFacedown() and Duel.GetMZoneCount(tp,c)>0
end
-- 手卡特殊召唤效果的发动准备、对象选择与合法性检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 检查场上是否存在可以作为对象的里侧表示怪兽。
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只里侧表示怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁处理中的操作信息，表示将对象怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置连锁处理中的操作信息，表示将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手卡特殊召唤效果的实际处理：将对象怪兽送去墓地，若成功送去，则将这张卡里侧守备表示特殊召唤并给对方确认。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，将其因效果送去墓地，并确认其是否成功送去墓地。
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将这张卡以里侧守备表示特殊召唤。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 让对方玩家确认里侧特殊召唤的这张卡。
			Duel.ConfirmCards(1-tp,c)
		end
	end
end
