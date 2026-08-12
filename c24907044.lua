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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方怪兽的攻击让自己受到战斗伤害时，可以从以下效果选择1个发动。
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
-- 判断是否满足效果发动条件：对方怪兽攻击并造成战斗伤害，且该怪兽在战斗中处于表侧表示状态
function c24907044.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	return ep==tp and a:IsControler(1-tp) and a:IsFaceup() and a:IsRelateToBattle()
end
-- 设置效果处理时的提示信息，提示对方玩家已选择效果
function c24907044.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家发送提示信息，显示已选择的效果描述
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行效果处理：将攻击怪兽的攻击力下降受到的战斗伤害数值
function c24907044.atkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	if tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsRelateToBattle() then
		-- 创建一个改变攻击力的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-ev)
		tc:RegisterEffect(e1)
	end
end
-- 定义过滤函数，用于筛选满足条件的灵摆怪兽
function c24907044.thfilter(c,atk)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(atk) and c:IsAbleToHand()
end
-- 设置效果处理时的提示信息，提示对方玩家已选择效果
function c24907044.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24907044.thfilter,tp,LOCATION_EXTRA,0,1,nil,ev) end
	-- 设置连锁操作信息，表示将要将灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家发送提示信息，显示已选择的效果描述
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行效果处理：从额外卡组选择符合条件的灵摆怪兽加入手牌
function c24907044.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c24907044.thfilter,tp,LOCATION_EXTRA,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选择的灵摆怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认送入手牌的灵摆怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置效果处理时的提示信息，提示对方玩家已选择效果
function c24907044.atktg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否存在满足条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要降低攻击力的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的对方怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行效果处理：将目标怪兽的攻击力下降受到的战斗伤害数值
function c24907044.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个改变攻击力的效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否满足效果发动条件：该卡被战斗或对方效果破坏，且在破坏前处于怪兽区域
function c24907044.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 定义过滤函数，用于筛选满足条件的「魔界台本」魔法卡
function c24907044.cfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 设置效果处理时的提示信息，提示对方玩家已选择效果
function c24907044.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24907044.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行效果处理：从卡组选择符合条件的魔法卡盖放
function c24907044.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c24907044.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的魔法卡盖放在场上
		Duel.SSet(tp,g)
	end
end
