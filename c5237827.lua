--ヴァイロン・オーム
-- 效果：
-- 这张卡召唤成功时，选择自己墓地存在的1张装备魔法卡从游戏中除外。下次的自己的准备阶段时把那张卡加入手卡。
function c5237827.initial_effect(c)
	-- 诱发必发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5237827,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c5237827.rmtg)
	e1:SetOperation(c5237827.rmop)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于筛选装备魔法卡
function c5237827.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToRemove()
end
-- 选择目标阶段，从自己墓地选择1张装备魔法卡作为除外对象
function c5237827.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5237827.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张装备魔法卡作为目标
	local g=Duel.SelectTarget(tp,c5237827.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，将被除外的卡加入到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理阶段，将选中的卡从游戏中除外并注册准备阶段效果
function c5237827.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功除外
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 为除外的卡注册一个准备阶段触发的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetCondition(c5237827.thcon)
		e1:SetOperation(c5237827.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		tc:RegisterEffect(e1)
	end
end
-- 准备阶段触发条件函数，判断是否轮到自己回合
function c5237827.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果处理函数，将除外的卡加入手牌
function c5237827.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡加入手牌
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
