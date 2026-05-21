--聖占術姫タロットレイ
-- 效果：
-- 「圣占术的仪式」降临。这个卡名的①②的效果1回合只能有1次使用其中任意1个，对方回合也能发动。
-- ①：以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ③：自己结束阶段才能发动。从自己的手卡·墓地选1只反转怪兽里侧守备表示特殊召唤。
function c94997874.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，对方回合也能发动。①：以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94997874,0))  --"变成表侧攻击表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_STANDBY_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,94997874)
	e1:SetTarget(c94997874.postg)
	e1:SetOperation(c94997874.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(94997874,1))  --"变成里侧守备表示"
	e2:SetTarget(c94997874.postg2)
	e2:SetOperation(c94997874.posop2)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段才能发动。从自己的手卡·墓地选1只反转怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94997874,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c94997874.spcon)
	e3:SetTarget(c94997874.sptg)
	e3:SetOperation(c94997874.spop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动准备：检查并选择场上1只里侧表示怪兽作为效果对象
function c94997874.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	-- 在发动准备阶段检查双方场上是否存在至少1只里侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示当前发动的效果（变成表侧攻击表示）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向发动玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让发动玩家选择1只里侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①号效果的效果处理：将作为对象的怪兽变成表侧攻击表示
function c94997874.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式改变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c94997874.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②号效果的发动准备：检查并选择场上1只表侧表示怪兽作为效果对象
function c94997874.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c94997874.posfilter(chkc) end
	-- 在发动准备阶段检查双方场上是否存在至少1只满足条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c94997874.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示当前发动的效果（变成里侧守备表示）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 向发动玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让发动玩家选择1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94997874.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 向对方玩家提示当前发动的效果（变成里侧守备表示）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②号效果的效果处理：将作为对象的怪兽变成里侧守备表示
function c94997874.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ③号效果的发动条件：当前回合是自己的回合
function c94997874.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动效果的玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：手卡·墓地的反转怪兽，且可以里侧守备表示特殊召唤
function c94997874.spfilter(c,e,tp)
	local proc=c:IsCode(42932862) and e:GetHandler():IsCode(94997874)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,proc,proc,POS_FACEDOWN_DEFENSE)
end
-- ③号效果的发动准备：检查自身怪兽区域是否有空位，且手卡·墓地是否存在可特殊召唤的反转怪兽
function c94997874.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的反转怪兽
		and Duel.IsExistingMatchingCard(c94997874.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示当前发动的效果（特殊召唤）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表示该效果包含从手卡·墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ③号效果的效果处理：从手卡·墓地选择1只反转怪兽里侧守备表示特殊召唤
function c94997874.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地（受王家长眠之谷影响）选择1只满足条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94997874.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local proc=tc:IsCode(42932862) and e:GetHandler():IsCode(94997874)
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,proc,proc,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,tc)
		if proc then tc:CompleteProcedure() end
	end
end
