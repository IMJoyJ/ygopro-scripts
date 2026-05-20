--マドルチェ・プディンセス
-- 效果：
-- ①：自己墓地没有怪兽存在的场合，这张卡的攻击力·守备力上升800。
-- ②：这张卡和对方怪兽进行战斗的伤害计算后，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
-- ③：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c74641045.initial_effect(c)
	-- ③：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74641045,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c74641045.retcon)
	e1:SetTarget(c74641045.rettg)
	e1:SetOperation(c74641045.retop)
	c:RegisterEffect(e1)
	-- ①：自己墓地没有怪兽存在的场合，这张卡的攻击力·守备力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c74641045.atkcon)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算后，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(74641045,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(c74641045.descon)
	e4:SetTarget(c74641045.destg)
	e4:SetOperation(c74641045.desop)
	c:RegisterEffect(e4)
end
-- 判断发动条件：这张卡在自己控制下被对方破坏并送去墓地
function c74641045.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 设置效果发动时的目标与操作信息：此效果为必发效果，直接返回true，并设置将自身送回卡组的操作信息
function c74641045.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自身（1张卡）送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行效果处理：若自身仍在墓地，则将自身送回卡组并洗牌
function c74641045.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判断攻击力·守备力上升效果的适用条件：自己墓地没有怪兽存在
function c74641045.atkcon(e)
	-- 检查自己墓地是否存在至少1张怪兽卡，若不存在则返回true
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 判断破坏效果的发动条件：这张卡和对方怪兽进行了战斗
function c74641045.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在攻击对象（即进行了怪兽之间的战斗）
	return Duel.GetAttackTarget()~=nil
end
-- 设置效果发动时的目标：选择对方场上1张卡作为对象，并设置破坏的操作信息
function c74641045.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在发动阶段（chk==0）检查对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏所选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果处理：将作为对象的卡破坏
function c74641045.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
