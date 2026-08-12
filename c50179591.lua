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
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。把对方的额外卡组确认，选那之内的1张除外。
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
-- 过滤函数，用于判断是否为表侧表示的「魔界剧团」怪兽
function c50179591.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
-- 设置效果目标为己方场上任意一只表侧表示的「魔界剧团」怪兽
function c50179591.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50179591.filter(chkc) end
	-- 检查己方场上是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c50179591.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c50179591.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 当效果发动时，为选中的怪兽注册一个标记，用于后续判断该怪兽是否触发了效果
function c50179591.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(50179591,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(50179591,0))  --"「魔界台本「火龙的住处」」效果适用中"
		-- 创建一个在战斗破坏怪兽时触发的效果，用于处理①的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetLabelObject(tc)
		e1:SetCondition(c50179591.rmcon1)
		e1:SetOperation(c50179591.rmop1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将上述效果注册到游戏环境，使其生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为被选中的怪兽触发的战斗破坏效果，并且该怪兽已标记了效果
function c50179591.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(50179591)~=0
end
-- 当满足条件时，从对方额外卡组中选择3只怪兽除外
function c50179591.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有可以除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()<3 then return end
	-- 显示发动卡片的动画提示
	Duel.Hint(HINT_CARD,0,50179591)
	-- 提示对方玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:Select(1-tp,3,3,nil)
	if mg:GetCount()>0 then
		-- 将选中的怪兽从对方额外卡组除外
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断盖放的这张卡是否被对方效果破坏，并且满足②的效果发动条件
function c50179591.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查己方额外卡组是否存在表侧表示的「魔界剧团」灵摆怪兽
		and Duel.IsExistingMatchingCard(c50179591.filter,tp,LOCATION_EXTRA,0,1,nil)
end
-- 设置效果处理时的操作信息，表明将要除外对方额外卡组中的怪兽
function c50179591.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组中是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置操作信息，表示本次效果将要处理的卡为对方额外卡组中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
-- 当②的效果发动时，确认对方额外卡组并选择1只怪兽除外
function c50179591.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组中所有怪兽
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if g:GetCount()==0 then return end
	-- 向玩家展示己方额外卡组中的所有怪兽
	Duel.ConfirmCards(tp,g,true)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local mg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	if mg:GetCount()>0 then
		-- 将选中的怪兽从对方额外卡组除外
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
	end
	-- 将对方额外卡组洗牌
	Duel.ShuffleExtra(1-tp)
end
