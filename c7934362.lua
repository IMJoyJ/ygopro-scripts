--Emファイヤー・ダンサー
-- 效果：
-- ←6 【灵摆】 6→
-- ①：1回合1次，以自己场上1只「娱乐法师」怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「娱乐法师 火舞者」以外的1只「娱乐法师」怪兽加入手卡。
-- ②：场上的这张卡被战斗·效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆属性设置、灵摆效果、召唤/特殊召唤时检索怪兽的效果以及被破坏时降低怪兽攻击力的效果。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤及灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只「娱乐法师」怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"赋予贯通"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「娱乐法师 火舞者」以外的1只「娱乐法师」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：场上的这张卡被战斗·效果破坏的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力降低"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 灵摆效果的发动条件：当前回合玩家能够进入战斗阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：自己场上表侧表示、属于「娱乐法师」系列且未拥有贯通效果的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6) and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 灵摆效果的发动准备阶段，进行合法性检查并选择自己场上1只表侧表示的「娱乐法师」怪兽作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足过滤条件的「娱乐法师」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只满足过滤条件的「娱乐法师」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果的处理阶段，为选择的对象怪兽赋予贯通效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：卡组中「娱乐法师 火舞者」以外的1只「娱乐法师」怪兽，且该卡能加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0xc6) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备阶段，检查卡组中是否存在可检索的怪兽并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足过滤条件的「娱乐法师」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示该效果包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理阶段，从卡组选择1只满足条件的「娱乐法师」怪兽加入手卡并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1只满足过滤条件的「娱乐法师」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽通过效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力下降效果的发动条件：场上的这张卡被战斗或效果破坏。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 攻击力下降效果的发动准备阶段，进行合法性检查并选择场上1只表侧表示怪兽作为对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 攻击力下降效果的处理阶段，使选择的对象怪兽攻击力下降500。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsFaceup() then
		-- 那只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
