--D-HERO ダークエンジェル
-- 效果：
-- ①：自己墓地的「命运英雄」怪兽是3只以上的场合，把这张卡从手卡丢弃，以自己墓地1只「命运英雄」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己发动的魔法卡的效果无效化并破坏。
-- ③：自己准备阶段，从自己墓地把这张卡和1只「命运英雄」怪兽除外才能发动。双方各自从自身卡组选1张通常魔法卡在卡组最上面放置。
function c26964762.initial_effect(c)
	-- ①：自己墓地的「命运英雄」怪兽是3只以上的场合，把这张卡从手卡丢弃，以自己墓地1只「命运英雄」怪兽为对象才能发动。那只怪兽在对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26964762,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c26964762.spcon)
	e1:SetCost(c26964762.spcost)
	e1:SetTarget(c26964762.sptg)
	e1:SetOperation(c26964762.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己发动的魔法卡的效果无效化并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(c26964762.disop)
	c:RegisterEffect(e2)
	-- ③：自己准备阶段，从自己墓地把这张卡和1只「命运英雄」怪兽除外才能发动。双方各自从自身卡组选1张通常魔法卡在卡组最上面放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26964762,1))  --"在卡组最上面放置"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(c26964762.deckcon)
	e3:SetCost(c26964762.deckcost)
	e3:SetTarget(c26964762.decktg)
	e3:SetOperation(c26964762.deckop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断墓地中的「命运英雄」怪兽
function c26964762.spcfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)
end
-- 效果条件函数，判断自己墓地是否有3只以上「命运英雄」怪兽
function c26964762.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组，检查自己墓地是否有3只以上「命运英雄」怪兽
	return Duel.IsExistingMatchingCard(c26964762.spcfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 效果费用函数，将自身送去墓地作为费用
function c26964762.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断是否可以特殊召唤的「命运英雄」怪兽
function c26964762.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 效果目标函数，设置选择目标的条件
function c26964762.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26964762.spfilter(chkc,e,tp) end
	-- 判断对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检索满足条件的卡片组，检查自己墓地是否有「命运英雄」怪兽可特殊召唤
		and Duel.IsExistingTarget(c26964762.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡片作为目标
	local g=Duel.SelectTarget(tp,c26964762.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将目标怪兽特殊召唤
function c26964762.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到对方场上
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果处理函数，使自己发动的魔法卡效果无效并破坏
function c26964762.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsActiveType(TYPE_SPELL) then
		local rc=re:GetHandler()
		-- 使连锁效果无效并判断是否可以破坏
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 破坏效果的发动卡片
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
-- 效果条件函数，判断是否为自己的准备阶段
function c26964762.deckcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，用于判断可作为除外费用的「命运英雄」怪兽
function c26964762.cfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果费用函数，选择除外的卡作为费用
function c26964762.deckcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检索满足条件的卡片组，检查自己墓地是否有「命运英雄」怪兽可除外
		and Duel.IsExistingMatchingCard(c26964762.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡片作为除外费用
	local g=Duel.SelectMatchingCard(tp,c26964762.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将卡片除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断是否为通常魔法卡
function c26964762.filter(c)
	return c:GetType()==TYPE_SPELL
end
-- 效果目标函数，设置选择目标的条件
function c26964762.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 检索满足条件的卡片组，检查自己卡组是否有通常魔法卡
		and Duel.IsExistingMatchingCard(c26964762.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数，双方各自从卡组选1张通常魔法卡放置在卡组最上面
function c26964762.deckop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26964762,3))  --"请选择要放置到卡组最上面的卡"
	-- 选择满足条件的卡作为放置在卡组最上面的卡
	local g1=Duel.SelectMatchingCard(tp,c26964762.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 提示对方玩家选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(26964762,3))  --"请选择要放置到卡组最上面的卡"
	-- 选择满足条件的卡作为对方放置在卡组最上面的卡
	local g2=Duel.SelectMatchingCard(1-tp,c26964762.filter,1-tp,LOCATION_DECK,0,1,1,nil)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1 then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将卡片移动到卡组最上方
		Duel.MoveSequence(tc1,SEQ_DECKTOP)
		-- 确认玩家卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
	if tc2 then
		-- 洗切对方的卡组
		Duel.ShuffleDeck(1-tp)
		-- 将卡片移动到对方卡组最上方
		Duel.MoveSequence(tc2,SEQ_DECKTOP)
		-- 确认对方卡组最上方的卡
		Duel.ConfirmDecktop(1-tp,1)
	end
end
