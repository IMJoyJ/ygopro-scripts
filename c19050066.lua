--EMバロックリボー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己·对方的战斗阶段开始时才能发动。从卡组把1只攻击力300/守备力200的怪兽加入手卡。那之后，这张卡破坏。
-- 【怪兽效果】
-- ①：自己怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
function c19050066.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性（灵摆召唤、灵摆卡的发动等），使其作为灵摆卡可在灵摆区放置并适用灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己·对方的战斗阶段开始时才能发动。从卡组把1只攻击力300/守备力200的怪兽加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c19050066.tgtg)
	e1:SetOperation(c19050066.tgop)
	c:RegisterEffect(e1)
	-- ①：自己怪兽被战斗破坏时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c19050066.descon)
	e2:SetTarget(c19050066.destg)
	e2:SetOperation(c19050066.desop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c19050066.atklimit)
	c:RegisterEffect(e3)
	-- ③：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetOperation(c19050066.posop)
	c:RegisterEffect(e4)
end
-- 定义检索过滤条件：只选择攻击力为300、守备力为200且能够加入手卡的怪兽。
function c19050066.tgfilter(c)
	return c:IsAttack(300) and c:IsDefense(200) and c:IsAbleToHand()
end
-- 效果发动时的合法性与操作信息设定：确认卡组存在符合条件的怪兽，并设定“加入手卡”和“破坏自身”的处理信息。
function c19050066.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的判定条件：卡组中是否存在至少1只满足攻击力300/守备力200且能加入手卡的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19050066.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将1只卡组的怪兽加入持有者手卡（处理时选择，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：效果处理时将这张灵摆卡（效果持有者）破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：从卡组选择1只符合条件的怪兽加入手卡并向对方确认；若加入成功且该卡仍处于手牌，则中断当前效果后破坏这张灵摆卡。
function c19050066.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1只满足攻击力300、守备力200且能加入手卡的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19050066.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡加入手卡，并检查是否成功加入且仍位于手牌（排除加入后被置换等情况），成功才执行后续破坏。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方玩家确认加入手卡的卡片，使其知道检索到的卡。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续的破坏效果作为不同的处理错开时点，对应“那之后”的结算。
		Duel.BreakEffect()
		-- 以效果原因破坏这张灵摆卡。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 筛选条件：被战斗破坏的怪兽的上一个控制者是tp（即“自己的怪兽被战斗破坏”）。
function c19050066.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 触发条件检查：被战斗破坏的怪兽集合中存在至少1只是自己（tp）控制的怪兽。
function c19050066.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19050066.cfilter,1,nil,tp)
end
-- 特殊召唤的发动条件：自己主要怪兽区有空位，且这张卡自身能够通过此效果特殊召唤。
function c19050066.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：效果处理时将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果相关（未离场或未被无效），将其表侧表示特殊召唤。
function c19050066.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧攻击表示将这张卡特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 永续效果的值：当攻击对象不是这张卡自身时，对方不能选择（即对方只能选择这张卡作为攻击对象）。
function c19050066.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 伤害步骤结束时的处理：若这张卡是被攻击的怪兽、处于守备表示且仍与战斗相关，则变为表侧攻击表示。
function c19050066.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定条件：这张卡就是攻击对象、当前是守备表示且仍与战斗相关。
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		-- 将这张卡的表示形式变为表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
