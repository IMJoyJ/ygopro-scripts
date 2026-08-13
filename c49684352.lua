--虹彩の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只魔法师族·暗属性怪兽为对象才能发动。这个回合中，以下效果适用。那之后，这张卡破坏。
-- ●作为对象的怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- 【怪兽效果】
-- 这张卡在规则上也当作「灵摆龙」卡使用。
-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「灵摆读阵」卡加入手卡。
function c49684352.initial_effect(c)
	-- 给这张卡注册灵摆怪兽的基本属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只魔法师族·暗属性怪兽为对象才能发动。这个回合中，以下效果适用。那之后，这张卡破坏。●作为对象的怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49684352,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c49684352.dbcon)
	e1:SetTarget(c49684352.dbtg)
	e1:SetOperation(c49684352.dbop)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「灵摆读阵」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49684352,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c49684352.thcon)
	e3:SetTarget(c49684352.thtg)
	e3:SetOperation(c49684352.thop)
	c:RegisterEffect(e3)
end
-- 该效果只能在回合玩家可以进入战斗阶段时发动。
function c49684352.dbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 对象怪兽的过滤条件：表侧表示、暗属性、魔法师族，且本回合未被此效果标记过（避免重复赋予伤害翻倍效果）。
function c49684352.dbfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:GetFlagEffect(49684352)==0
end
-- 取对象的目标选择处理：选择自己场上1只符合条件的暗属性魔法师族怪兽，并设置将这张卡破坏的操作信息。
function c49684352.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49684352.dbfilter(chkc) end
	-- 非处理时，检查自己场上是否存在至少1只符合条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c49684352.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择表侧表示怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合条件的暗属性魔法师族怪兽作为效果对象。
	Duel.SelectTarget(tp,c49684352.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果处理将破坏这张卡（效果持有者）1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与效果关联，给对象怪兽赋予战斗伤害翻倍效果，然后将这张卡自身破坏。
function c49684352.dbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(49684352,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		-- ●作为对象的怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(c49684352.damcon)
		-- 设置伤害倍率：对象怪兽给予对方的战斗伤害变为2倍（由对手承受）。
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 中断当前效果，使后续的破坏处理与之前的伤害翻倍效果处理视为不同时处理（避免错时点）。
		Duel.BreakEffect()
		-- 用效果将这张卡（灵摆区的虹彩之魔术师）破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 伤害翻倍效果的适用条件：该怪兽正在与对方怪兽进行战斗。
function c49684352.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 触发条件：这张卡被战斗或效果破坏时满足。
function c49684352.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 检索的卡须为「灵摆读阵」卡，且能够加入手卡。
function c49684352.thfilter(c)
	return c:IsSetCard(0x20f2) and c:IsAbleToHand()
end
-- 检索效果的目标：确认卡组存在符合条件的卡片，并设置从卡组加入手卡的操作信息。
function c49684352.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非处理时，检查卡组是否存在至少1张符合条件的「灵摆读阵」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49684352.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理将1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「灵摆读阵」卡加入手卡，并让对方确认。
function c49684352.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择要加入手牌的卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「灵摆读阵」卡。
	local g=Duel.SelectMatchingCard(tp,c49684352.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
