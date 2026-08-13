--海造賊－静寂のメルケ号
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张「海造贼」卡，以对方场上1只效果怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1张「海造贼」魔法·陷阱卡加入手卡。这张卡有「海造贼」卡装备的场合，这个效果在对方回合也能发动。
-- ②：自己场上的「海造贼」卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c20248754.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用等级4的怪兽2只作为超量素材特殊召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：从手卡丢弃1张「海造贼」卡，以对方场上1只效果怪兽为对象才能发动。那只怪兽除外。那之后，可以从卡组把1张「海造贼」魔法·陷阱卡加入手卡。这张卡有「海造贼」卡装备的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20248754,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20248754)
	e1:SetCondition(c20248754.rmcon1)
	e1:SetCost(c20248754.rmcost)
	e1:SetTarget(c20248754.rmtg)
	e1:SetOperation(c20248754.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c20248754.rmcon2)
	c:RegisterEffect(e2)
	-- ②：自己场上的「海造贼」卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c20248754.reptg)
	e3:SetValue(c20248754.repval)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否为表侧表示且具有「海造贼」字段（0x13f），用于检查装备区的「海造贼」卡。
function c20248754.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f)
end
-- ①效果的发动条件：这张卡没有装备「海造贼」卡时才能发动（即非装备状态）。若没有装备组或装备组中不存在满足条件的「海造贼」卡则返回真。
function c20248754.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return not g or not g:IsExists(c20248754.confilter,1,nil)
end
-- 额外效果的发动条件：这张卡装备有「海造贼」卡时才能发动（此时可在对方回合发动）。若装备组中存在满足条件的「海造贼」卡则返回真。
function c20248754.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup()
	return g and g:IsExists(c20248754.confilter,1,nil)
end
-- 代价筛选函数：从手卡选择1张可以丢弃的「海造贼」卡。
function c20248754.costfilter(c)
	return c:IsSetCard(0x13f) and c:IsDiscardable()
end
-- ①效果的费用：检查手卡是否存在符合条件的「海造贼」卡，然后丢弃1张手卡的「海造贼」卡作为发动代价。
function c20248754.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查：若在发动确认阶段（chk==0），判断手卡是否有至少1张可丢弃的「海造贼」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c20248754.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃：从手卡选择1张「海造贼」卡以COST+丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c20248754.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象筛选函数：对方场上的表侧表示效果怪兽，且可以被除外。
function c20248754.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToRemove()
end
-- ①效果的发动目标处理：选择对方场上1只表侧表示效果怪兽为对象，并设置除外相关信息。
function c20248754.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c20248754.rmfilter(chkc) end
	-- 目标检查：若在发动确认阶段，判断对方场上是否存在满足条件的表侧表示效果怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20248754.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上的1只效果怪兽作为对象，并自动记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c20248754.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：本效果将除外1张卡（对象确定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 检索筛选函数：从卡组选择1张「海造贼」魔法·陷阱卡，且能够加入手卡。
function c20248754.thfilter(c)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果处理：先除外对象怪兽，若除外成功且卡组存在「海造贼」魔法·陷阱卡，则询问玩家是否检索；选择后将卡加入手卡并给对方确认。
function c20248754.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象（即被选择要除外的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 条件判断：对象仍与效果关联且除外成功，并且卡组有可检索的「海造贼」魔法·陷阱卡，然后询问玩家是否检索。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c20248754.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(20248754,1)) then  --"是否从卡组把「海造贼」魔法·陷阱卡加入手卡？"
		-- 中断当前效果链，使后续检索处理不再与除外效果视为同时处理（避免错失时点）。
		Duel.BreakEffect()
		-- 向玩家显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张符合条件的「海造贼」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c20248754.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的卡加入持有者手卡（nil表示加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏的判定函数：自己场上的表侧「海造贼」卡将要被战斗或效果破坏，且不是被代替效果破坏的场合，符合条件。
function c20248754.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x13f) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的触发条件：存在满足条件的将被破坏的「海造贼」卡，且这张卡有1个超量素材可以取除。
function c20248754.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c20248754.repfilter,1,nil,tp)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动②效果代替破坏：选择是则取除1个超量素材并返回真，否则返回假。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	end
	return false
end
-- 代替破坏的值判定：对于将被破坏的卡c，判断其是否满足自己场上的「海造贼」卡被战斗/效果破坏的条件。
function c20248754.repval(e,c)
	return c20248754.repfilter(c,e:GetHandlerPlayer())
end
