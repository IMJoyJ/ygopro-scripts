--虹彩の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只魔法师族·暗属性怪兽为对象才能发动。这个回合中，以下效果适用。那之后，这张卡破坏。
-- ●作为对象的怪兽用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
-- 【怪兽效果】
-- 这张卡在规则上也当作「灵摆龙」卡使用。
-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「灵摆读阵」卡加入手卡。
function c49684352.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只魔法师族·暗属性怪兽为对象才能发动。这个回合中，以下效果适用。那之后，这张卡破坏。
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
-- 判断是否可以进入战斗阶段
function c49684352.dbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示、暗属性、魔法师族且未被使用过此效果）
function c49684352.dbfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:GetFlagEffect(49684352)==0
end
-- 设置选择目标的过滤条件和提示信息，并设定操作信息为破坏自身
function c49684352.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49684352.dbfilter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c49684352.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示其选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c49684352.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息，指定将要破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理效果发动后的操作，包括注册标志、添加战斗伤害翻倍效果并破坏自身
function c49684352.dbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(49684352,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		-- 创建一个改变战斗伤害的效果，使对方受到的战斗伤害变为2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(c49684352.damcon)
		-- 设置该效果的值为双倍伤害
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 中断当前效果处理流程，防止错时点
		Duel.BreakEffect()
		-- 将自身破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 判断目标怪兽是否参与了战斗
function c49684352.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- 判断被破坏的原因是否为战斗或效果破坏
function c49684352.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤函数，用于筛选「灵摆读阵」卡组中的可加入手牌的卡
function c49684352.thfilter(c)
	return c:IsSetCard(0x20f2) and c:IsAbleToHand()
end
-- 设置检索「灵摆读阵」卡的效果目标和操作信息
function c49684352.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「灵摆读阵」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c49684352.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索并加入手牌的操作，包括提示选择、发送至手牌和确认卡片
function c49684352.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「灵摆读阵」卡
	local g=Duel.SelectMatchingCard(tp,c49684352.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
