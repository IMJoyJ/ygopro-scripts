--魔界台本「火竜の住処」
-- 效果：
-- 「魔界台本「火龙的住处」」的②的效果1回合只能使用1次。
-- ①：以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，那只怪兽战斗破坏对方怪兽的场合，对方从额外卡组选3只怪兽除外。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。把对方的额外卡组确认，选那之内的1张除外。
function c50179591.initial_effect(c)
	-- ①：以自己场上1只「魔界剧团」怪兽为对象才能发动。这个回合，那只怪兽战斗破坏对方怪兽的场合，对方从额外卡组选3只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50179591.target)
	e1:SetOperation(c50179591.operation)
	c:RegisterEffect(e1)
	-- 「魔界台本「火龙的住处」」的②的效果1回合只能使用1次。②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。把对方的额外卡组确认，选那之内的1张除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50179591,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,50179591)
	e2:SetCondition(c50179591.rmcon2)
	e2:SetTarget(c50179591.rmtg2)
	e2:SetOperation(c50179591.rmop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且属于「魔界剧团」系列（0x10ec），用于筛选符合条件的「魔界剧团」怪兽。
function c50179591.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- ①效果的取对象处理：在发动时以自己场上1只表侧表示「魔界剧团」怪兽为对象进行选择，并完成发动合法性的检查。
function c50179591.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50179591.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只满足条件的表侧表示「魔界剧团」怪兽可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c50179591.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡，将选择提示写入缓存，供后续选择界面显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧表示「魔界剧团」怪兽，并将选中的卡登记为此效果的取对象。
	Duel.SelectTarget(tp,c50179591.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：为对象怪兽打上此效果适用中的标志，并注册一个持续效果，监听该怪兽在回合内战斗破坏对方怪兽的事件。
function c50179591.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象怪兽（取对象目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(50179591,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(50179591,0))  --"「魔界台本「火龙的住处」」效果适用中"
		-- 这个回合，那只怪兽战斗破坏对方怪兽的场合，对方从额外卡组选3只怪兽除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetLabelObject(tc)
		e1:SetCondition(c50179591.rmcon1)
		e1:SetOperation(c50179591.rmop1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将此持续效果注册到当前决斗中，由tp方管理，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 触发条件判断：检查当前战斗破坏对方怪兽的事件中是否包含被标记的对象怪兽（即之前选中的「魔界剧团」怪兽），且标志仍存在。
function c50179591.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(50179591)~=0
end
-- 战斗破坏后除外处理：取得对方额外卡组所有可除外的卡，若不足3张则效果不适用；否则由对方选择3张卡除外。
function c50179591.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有满足可除外条件的卡片集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()<3 then return end
	-- 展示该卡的效果动画/提示，告知本次不入连锁的除外处理由魔界台本效果触发。
	Duel.Hint(HINT_CARD,0,50179591)
	-- 提示对方选择要除外的卡（选择消息为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:Select(1-tp,3,3,nil)
	if mg:GetCount()>0 then
		-- 将选中的卡片以表侧表示除外，原因记为效果。
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果发动条件检查：这张卡为盖放状态、由对方的效果破坏，且破坏前由自己控制并位于场上，同时自己额外卡组存在表侧表示「魔界剧团」灵摆怪兽。
function c50179591.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 额外条件：确认自己额外卡组存在至少1张表侧表示且属于「魔界剧团」系列的卡（即原文的表侧表示「魔界剧团」灵摆怪兽）。
		and Duel.IsExistingMatchingCard(c50179591.filter,tp,LOCATION_EXTRA,0,1,nil)
end
-- ②效果的发动检查与操作信息设置：确认对方额外卡组有可除外的卡；随后设置本次处理为除外对方额外卡组的1张卡。
function c50179591.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方额外卡组存在至少1张可以除外的卡，否则②不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置操作信息：本次效果属除外分类，预计处理数量为1；目标不固定，在处理时从对方额外卡组选择。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
-- ②效果处理：先确认对方额外卡组全部卡片，再由自己选择其中1张可以除外的卡除外，最后洗切对方额外卡组。
function c50179591.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方额外卡组的全部卡片，用于确认和选择。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if g:GetCount()==0 then return end
	-- 向自己展示对方额外卡组的全部卡片，以便选择要除外的卡。
	Duel.ConfirmCards(tp,g,true)
	-- 提示自己选择要除外的卡（选择消息为“请选择要除外的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	if mg:GetCount()>0 then
		-- 将选中的那张卡以表侧表示除外，原因记为效果。
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
	-- 洗切对方的额外卡组（因确认过额外卡组，处理后需要重新洗切）。
	Duel.ShuffleExtra(1-tp)
end
