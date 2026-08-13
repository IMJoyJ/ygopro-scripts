--魔界劇団－プリティ・ヒロイン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，对方怪兽的攻击让自己受到战斗伤害时，可以从以下效果选择1个发动。
-- ●那只对方怪兽的攻击力下降受到的伤害的数值。
-- ●从自己的额外卡组把持有受到的伤害数值以下的攻击力的1只表侧表示的「魔界剧团」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：1回合1次，自己或者对方受到战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降那次战斗伤害的数值。
-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏时才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。
function c24907044.initial_effect(c)
	-- 为这张卡添加灵摆召唤和灵摆卡发动所需的灵摆怪兽属性，使它能在灵摆区域作为灵摆卡处理。
	aux.EnablePendulumAttribute(c)
	-- ●那只对方怪兽的攻击力下降受到的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24907044,0))  --"攻击力下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c24907044.atkcon1)
	e1:SetTarget(c24907044.atktg1)
	e1:SetOperation(c24907044.atkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(24907044,1))  --"额外卡组灵摆怪兽加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetTarget(c24907044.thtg)
	e2:SetOperation(c24907044.thop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己或者对方受到战斗伤害时，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降那次战斗伤害的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24907044,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c24907044.atktg2)
	e3:SetOperation(c24907044.atkop2)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被战斗或者对方的效果破坏时才能发动。从卡组选1张「魔界台本」魔法卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24907044,3))
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c24907044.setcon)
	e4:SetTarget(c24907044.settg)
	e4:SetOperation(c24907044.setop)
	c:RegisterEffect(e4)
end
-- 检查战斗伤害事件是否为对方怪兽攻击自己造成的战斗伤害，且攻击怪兽表侧表示并仍与战斗相关，作为灵摆效果①的发动条件。
function c24907044.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取造成本次战斗伤害的攻击怪兽。
	local a=Duel.GetAttacker()
	return ep==tp and a:IsControler(1-tp) and a:IsFaceup() and a:IsRelateToBattle()
end
-- 灵摆效果①的发动时点无额外对象选择和发动条件以外的限制，满足条件即可发动，并向对方提示本次选择的效果。
function c24907044.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示我方选择发动的效果描述，便于对方知晓选择了哪个可选效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 灵摆效果①的处理：让那只对方攻击怪兽的攻击力下降所受战斗伤害的数值，创建一个持续下降攻击力的效果并注册给该怪兽。
function c24907044.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽作为下降攻击力的对象。
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力下降受到的伤害的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-ev)
		tc:RegisterEffect(e1)
	end
end
-- 定义额外卡组检索的过滤条件：表侧表示的「魔界剧团」灵摆怪兽，攻击力在所受伤害数值以下，且可以加入手卡。
function c24907044.thfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
-- 第二个可选效果的发动判定和目标设置：检查额外卡组是否有符合条件的卡，设置将卡加入手卡的操作信息，并提示对方选择了该效果。
function c24907044.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1张攻击力在所受伤害数值以下且满足条件的「魔界剧团」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24907044.thfilter,tp,LOCATION_EXTRA,0,1,nil,ev) end
	-- 设置本连锁的操作信息：效果处理时将从额外卡组把1张卡加入手卡，供连锁判定和后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示我方选择了从额外卡组加入手卡的这个灵摆效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 第二个可选效果的处理：从额外卡组选择1张符合条件的「魔界剧团」灵摆怪兽加入手卡，并让对方确认加入的卡片。
function c24907044.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示框，要求我方选择一张要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中筛选并选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c24907044.thfilter,tp,LOCATION_EXTRA,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认通过这个效果加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果①的取对象目标处理：检查并选择对方场上1只表侧表示怪兽作为对象，该效果为取对象效果。
function c24907044.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示框，要求我方选择一只对方场上的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只对方场上表侧表示怪兽作为效果对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 怪兽效果①的处理：将对象怪兽的攻击力下降那次战斗伤害的数值，创建持续下降攻击力的效果并注册给该对象。
function c24907044.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力下降那次战斗伤害的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果②的发动条件：这张卡在怪兽区域被战斗破坏，或被对方玩家的效果破坏，且破坏前控制权属于我方并位于主要怪兽区时才能发动。
function c24907044.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 定义卡组检索过滤条件：选择卡组中「魔界台本」魔法卡且当前可以盖放在场上的卡。
function c24907044.cfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 怪兽效果②的发动判定：检查卡组是否存在至少1张符合条件的「魔界台本」魔法卡。
function c24907044.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的「魔界台本」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24907044.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 怪兽效果②的处理：从卡组选择1张「魔界台本」魔法卡，在自己场上盖放。
function c24907044.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示框，要求我方选择一张要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中筛选并选择1张满足cfilter条件的「魔界台本」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c24907044.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「魔界台本」魔法卡以里侧表示盖放到自己场上。
		Duel.SSet(tp,g)
	end
end
