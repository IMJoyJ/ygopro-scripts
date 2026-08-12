--魔界台本「ファンタジー・マジック」
-- 效果：
-- ①：以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，没被和那只怪兽的战斗破坏的怪兽在伤害步骤结束时回到持有者手卡。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组最上面。
function c87390798.initial_effect(c)
	-- ①：以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，没被和那只怪兽的战斗破坏的怪兽在伤害步骤结束时回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c87390798.target)
	e1:SetOperation(c87390798.activate)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87390798,0))  --"「魔界台本「幻想魔法」」效果适用中"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c87390798.tdcon)
	e2:SetTarget(c87390798.tdtg)
	e2:SetOperation(c87390798.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「魔界剧团」怪兽
function c87390798.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- 效果①的发动准备（选择自己场上1只「魔界剧团」怪兽作为对象）
function c87390798.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87390798.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「魔界剧团」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87390798.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「魔界剧团」怪兽作为对象
	Duel.SelectTarget(tp,c87390798.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：给对象怪兽注册标记，并注册一个在伤害步骤结束时触发的全局效果
function c87390798.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(87390798,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(87390798,0))  --"「魔界台本「幻想魔法」」效果适用中"
		-- 这个回合，没被和那只怪兽的战斗破坏的怪兽在伤害步骤结束时回到持有者手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetLabelObject(tc)
		e1:SetCondition(c87390798.retcon)
		e1:SetOperation(c87390798.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境注册该回合内生效的延迟回手卡效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查作为对象的怪兽是否仍带有该效果的适用标记
function c87390798.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(87390798)~=0
end
-- 伤害步骤结束时，将与该怪兽进行战斗且未被战斗破坏的对方怪兽送回持有者手卡
function c87390798.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if bc and not bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsRelateToBattle() then
		-- 将该怪兽送回持有者手卡
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：额外卡组表侧表示的「魔界剧团」灵摆怪兽
function c87390798.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 效果②的发动条件：盖放的这张卡被对方效果破坏，且自己额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在
function c87390798.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查自己额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c87390798.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 效果②的发动准备（选择对方场上1张卡作为对象，并设置操作信息）
function c87390798.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查对方场上是否存在可以返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上1张可以返回卡组的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理：将作为对象的卡回到持有者卡组最上面
function c87390798.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡送回持有者卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
