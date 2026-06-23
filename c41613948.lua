--D-HERO デビルガイ
-- 效果：
-- 这张卡在自己场上表侧攻击表示存在的场合，1回合只有1次，可以把1只对方怪兽从游戏中除外。使用这个效果的玩家在这个回合不能进行战斗。这个效果除外的怪兽在第2次自己的准备阶段时以相同的表示形式回到对方场上。
function c41613948.initial_effect(c)
	-- 这张卡在自己场上表侧攻击表示存在的场合，1回合只有1次，可以把1只对方怪兽从游戏中除外。使用这个效果的玩家在这个回合不能进行战斗。这个效果除外的怪兽在第2次自己的准备阶段时以相同的表示形式回到对方场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41613948,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c41613948.condition)
	e1:SetCost(c41613948.cost)
	e1:SetTarget(c41613948.target)
	e1:SetOperation(c41613948.operation)
	c:RegisterEffect(e1)
end
-- 这张卡在自己场上表侧攻击表示存在的场合
function c41613948.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 使用这个效果的玩家在这个回合不能进行战斗
function c41613948.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 使用这个效果的玩家在这个回合不能进行战斗
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 这个效果除外的怪兽在第2次自己的准备阶段时以相同的表示形式回到对方场上。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击宣言效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 选择1只对方怪兽作为除外对象
function c41613948.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 确认场上存在可除外的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 将目标怪兽除外并设置返回效果
function c41613948.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 确认效果有效且目标怪兽存在并成功除外
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 设置准备阶段时触发的返回效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e1:SetCountLimit(1)
		e1:SetCondition(c41613948.retcon)
		e1:SetOperation(c41613948.retop)
		e1:SetLabel(1)
		e1:SetLabelObject(tc)
		-- 将返回效果注册给全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为当前回合玩家
function c41613948.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段时处理返回效果
function c41613948.retop(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetLabel()
	if t==1 then e:SetLabel(0)
	-- 将除外的怪兽以原表示形式返回对方场上
	else Duel.ReturnToField(e:GetLabelObject())	end
end
