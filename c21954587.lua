--水精鱗－メガロアビス
-- 效果：
-- ①：从手卡把这张卡以外的2只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1张「深渊」魔法·陷阱卡加入手卡。
-- ③：把这张卡以外的自己场上1只表侧攻击表示的水属性怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c21954587.initial_effect(c)
	-- ①：从手卡把这张卡以外的2只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21954587,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c21954587.spcost)
	e1:SetTarget(c21954587.sptg)
	e1:SetOperation(c21954587.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1张「深渊」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21954587,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c21954587.thcon)
	e2:SetTarget(c21954587.thtg)
	e2:SetOperation(c21954587.thop)
	c:RegisterEffect(e2)
	-- ③：把这张卡以外的自己场上1只表侧攻击表示的水属性怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21954587,2))  --"两次攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c21954587.atkcon)
	e3:SetCost(c21954587.atkcost)
	e3:SetTarget(c21954587.atktg)
	e3:SetOperation(c21954587.atkop)
	c:RegisterEffect(e3)
end
-- 定义丢弃代价的筛选函数：需要水属性、可以丢弃、并且可以作为代价送去墓地。
function c21954587.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果①的代价处理：先检查手卡中是否存在2张满足条件的卡（不能选自身），若满足则丢弃这2张水属性怪兽作为发动代价。
function c21954587.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认手卡中存在至少2张满足代价条件且不是这张卡本身的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21954587.cfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 实际执行代价：从手卡丢弃2张满足条件的水属性怪兽（不包含这张卡），丢弃原因视为代价丢弃。
	Duel.DiscardHand(tp,c21954587.cfilter,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 特殊召唤的目标阶段：确认我方主要怪兽区有空位，且这张卡本身可以被特殊召唤。
function c21954587.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上的主要怪兽区是否有空位，用于判断能否从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息：本次效果处理时将把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理函数：若这张卡仍与效果关联，则将其以表侧攻击表示特殊召唤到我方场上。
function c21954587.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以自身效果的方式将这张卡特殊召唤，不检查召唤条件与苏生限制，表示形式为表侧攻击表示。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- ②的诱发条件：这张卡以①的效果（自身效果）特殊召唤成功时才能发动，通过召唤类型判断确实是①的效果。
function c21954587.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 检索筛选条件：卡名含有「深渊」字段的魔法·陷阱卡，并且可以加入手牌。
function c21954587.thfilter(c)
	return c:IsSetCard(0x75) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②的发动目标：确认卡组中存在至少1张符合条件的「深渊」魔法·陷阱卡，并设置加入手牌的操作信息。
function c21954587.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：卡组中是否存在至少1张满足「深渊」魔法·陷阱卡且可加入手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21954587.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理时从卡组将1张卡加入手牌（数量为1，来源为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索处理：提示玩家选择，从卡组选1张符合条件的「深渊」魔法·陷阱卡加入手牌，然后让对方确认。
function c21954587.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，提示文本为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足检索条件的「深渊」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c21954587.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把实际加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③的发动条件：当前回合玩家可以进入战斗阶段时才能发动。
function c21954587.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否满足进入战斗阶段的条件，以此限制效果只能在主要阶段且可攻击的回合使用。
	return Duel.IsAbleToEnterBP()
end
-- 解放筛选条件：怪兽为表侧攻击表示，且属性为水属性。
function c21954587.rfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 解放代价处理：先检查场上是否存在至少1只满足条件且不是这张卡本身的可解放水属性怪兽，再选择1只解放作为代价。
function c21954587.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认我方场上存在至少1只除自身以外的表侧攻击表示水属性怪兽可供解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c21954587.rfilter,1,e:GetHandler()) end
	-- 选择1只除自身以外的表侧攻击表示水属性怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c21954587.rfilter,1,1,e:GetHandler())
	-- 解放选择的怪兽，解放原因记为代价。
	Duel.Release(g,REASON_COST)
end
-- ③的目标条件：这张卡尚未获得额外攻击次数效果，避免重复适用。
function c21954587.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果处理：给这张卡注册一个仅在当前回合有效的额外攻击次数效果，使其本回合战斗阶段可以攻击2次。
function c21954587.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
