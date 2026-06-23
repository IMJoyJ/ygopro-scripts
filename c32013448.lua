--宵闇の騎士
-- 效果：
-- 「宵暗之骑士」的①②的效果1回合各能使用1次。
-- ①：使用这张卡仪式召唤的「混沌战士」怪兽得到以下效果。
-- ●1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
-- ●1回合1次，自己主要阶段才能发动。对方手卡随机选1张直到下次的对方结束阶段里侧表示除外。
-- ②：墓地的这张卡被除外的场合才能发动。从卡组把1只仪式怪兽加入手卡。
function c32013448.initial_effect(c)
	-- 创建一个永续效果，当这张卡作为仪式召唤的素材时触发
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,32013448)
	e1:SetCondition(c32013448.mtcon)
	e1:SetOperation(c32013448.mtop)
	c:RegisterEffect(e1)
	-- 墓地的这张卡被除外的场合才能发动。从卡组把1只仪式怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,32013449)
	e2:SetCondition(c32013448.thcon)
	e2:SetTarget(c32013448.thtg)
	e2:SetOperation(c32013448.thop)
	c:RegisterEffect(e2)
end
-- 判断是否为仪式召唤的素材且为混沌战士族，且不是从超量位置被除外
function c32013448.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and eg:IsExists(Card.IsSetCard,1,nil,0x10cf)
		and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 将「宵暗之骑士」的效果赋予使用这张卡仪式召唤的「混沌战士」怪兽，使其获得两个效果
function c32013448.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x10cf)
	local rc=g:GetFirst()
	if not rc then return end
	-- 1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(32013448,0))  --"对方场上1只怪兽除外（宵暗之骑士）"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c32013448.rmtg)
	e1:SetOperation(c32013448.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	-- 1回合1次，自己主要阶段才能发动。对方手卡随机选1张直到下次的对方结束阶段里侧表示除外。
	local e2=Effect.CreateEffect(rc)
	e2:SetDescription(aux.Stringid(32013448,1))  --"对方手卡随机1张暂时除外（宵暗之骑士）"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c32013448.rmtg2)
	e2:SetOperation(c32013448.rmop2)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若该怪兽不是效果怪兽，则添加效果怪兽属性
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(32013448,2))  --"「宵暗之骑士」效果适用中"
end
-- 设置选择目标的提示信息
function c32013448.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查是否存在满足条件的对方场上怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作
function c32013448.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 设置选择目标的提示信息
function c32013448.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的对方手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	-- 设置操作信息，表示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 执行对方手卡随机除外并设置返回手牌的效果
function c32013448.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中所有可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	local tc=sg:GetFirst()
	-- 将目标卡以里侧表示除外
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	tc:RegisterFlagEffect(32013448,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 注册一个在对方结束阶段时将卡返回手牌的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c32013448.retcon)
	e1:SetOperation(c32013448.retop)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否满足返回手牌的条件
function c32013448.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(32013448)==0 then
		e:Reset()
		return false
	else
		-- 判断当前回合玩家是否为发动者
		return Duel.GetTurnPlayer()~=tp
	end
end
-- 执行将卡返回手牌的操作
function c32013448.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将卡送入手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 判断该卡是否从墓地被除外
function c32013448.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 过滤函数，用于筛选可加入手牌的卡
function c32013448.thfilter(c)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsAbleToHand()
end
-- 设置检索卡组的提示信息
function c32013448.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32013448.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c32013448.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c32013448.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
