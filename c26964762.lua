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
-- 判断卡片是否属于「命运英雄」系列的怪兽卡，用于筛选墓地中的命运英雄怪兽。
function c26964762.spcfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动条件：自己墓地存在3只以上「命运英雄」怪兽。
function c26964762.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少3只「命运英雄」怪兽。
	return Duel.IsExistingMatchingCard(c26964762.spcfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- ①效果的发动代价：将手牌中的这张卡丢弃送入墓地。
function c26964762.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌丢弃送入墓地，作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选墓地中可作为特殊召唤对象的「命运英雄」怪兽，要求能被特殊召唤到对方场上且以表侧守备表示出场。
function c26964762.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ①效果发动时：选择自己墓地1只「命运英雄」怪兽为对象，并设置特殊召唤的操作信息。
function c26964762.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c26964762.spfilter(chkc,e,tp) end
	-- 确认对方怪兽区域存在可用的空格，保证特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 并确认自己墓地存在1只符合条件的「命运英雄」怪兽可以作为对象。
		and Duel.IsExistingTarget(c26964762.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示框，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「命运英雄」怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c26964762.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将进行特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将作为对象的那只「命运英雄」怪兽特殊召唤到对方场上表侧守备表示。
function c26964762.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到对方场上，表示形式为表侧守备表示。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的触发处理：自己发动魔法卡时，使那张魔法卡的效果无效化并破坏。
function c26964762.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsActiveType(TYPE_SPELL) then
		local rc=re:GetHandler()
		-- 先将该魔法卡的效果无效化；若无效成功且该卡仍与连锁相关，则继续执行破坏。
		if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
			-- 以效果破坏那张魔法卡。
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end
-- ③效果的发动条件：自己准备阶段且当前回合玩家为自己。
function c26964762.deckcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是自己，即在自己准备阶段时满足条件。
	return Duel.GetTurnPlayer()==tp
end
-- 判断卡片是否属于「命运英雄」怪兽且可作为代价除外，用于③效果中额外除外的怪兽选择。
function c26964762.cfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ③效果的发动代价：从自己墓地将这张卡和另1只「命运英雄」怪兽除外。
function c26964762.deckcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 并确认自己墓地存在至少1只除这张卡以外的「命运英雄」怪兽可作为代价除外。
		and Duel.IsExistingMatchingCard(c26964762.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 弹出选择提示，让玩家选择要除外的「命运英雄」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只除这张卡以外的「命运英雄」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c26964762.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将代价卡组（包含自身和选择的「命运英雄」怪兽）以表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 筛选通常魔法卡（类型仅为魔法卡，不包含速攻、装备、永续、场地、仪式等）。
function c26964762.filter(c)
	return c:GetType()==TYPE_SPELL
end
-- ③效果发动时确认对方卡组有卡且自己卡组存在通常魔法卡。
function c26964762.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方卡组有卡，保证对方能进行选卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		-- 确认自己卡组存在至少1张通常魔法卡，保证自己能够选卡。
		and Duel.IsExistingMatchingCard(c26964762.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- ③效果处理：双方各从自己的卡组选1张通常魔法卡，然后分别放置到各自卡组最上面。
function c26964762.deckop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让己方玩家选择要放置到卡组最上方的通常魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26964762,3))  --"请选择要放置到卡组最上面的卡"
	-- 己方玩家从自己卡组选择1张通常魔法卡。
	local g1=Duel.SelectMatchingCard(tp,c26964762.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 弹出选择提示，让对方玩家选择要放置到卡组最上方的通常魔法卡。
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(26964762,3))  --"请选择要放置到卡组最上面的卡"
	-- 对方玩家从对方自己的卡组选择1张通常魔法卡。
	local g2=Duel.SelectMatchingCard(1-tp,c26964762.filter,1-tp,LOCATION_DECK,0,1,1,nil)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	if tc1 then
		-- 洗切己方卡组，为将选中的卡移至卡组顶做准备。
		Duel.ShuffleDeck(tp)
		-- 将己方选中的通常魔法卡移动到卡组最上方。
		Duel.MoveSequence(tc1,SEQ_DECKTOP)
		-- 向双方确认己方卡组最上方的卡是这张通常魔法卡。
		Duel.ConfirmDecktop(tp,1)
	end
	if tc2 then
		-- 洗切对方卡组，为将选中的卡移至卡组顶做准备。
		Duel.ShuffleDeck(1-tp)
		-- 将对方选中的通常魔法卡移动到对方卡组最上方。
		Duel.MoveSequence(tc2,SEQ_DECKTOP)
		-- 向双方确认对方卡组最上方的卡是这张通常魔法卡。
		Duel.ConfirmDecktop(1-tp,1)
	end
end
