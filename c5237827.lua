--ヴァイロン・オーム
-- 效果：
-- 这张卡召唤成功时，选择自己墓地存在的1张装备魔法卡从游戏中除外。下次的自己的准备阶段时把那张卡加入手卡。
function c5237827.initial_effect(c)
	-- 这张卡召唤成功时，选择自己墓地存在的1张装备魔法卡从游戏中除外。
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
-- 筛选自己墓地中存在的装备魔法卡，且该卡可以被除外。
function c5237827.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择处理：确认对象合法后，提示玩家选择自己墓地1张装备魔法卡作为对象，并设置除外相关的操作信息。
function c5237827.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5237827.filter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要除外的卡”的提示，引导玩家从墓地选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足条件的装备魔法卡，并将其登记为本次效果的对象。
	local g=Duel.SelectTarget(tp,c5237827.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次效果的操作信息为除外，对象为已选择的卡，数量为1，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理时取出对象卡；若对象仍与效果关联，则将其表侧除外，并给该卡注册一个“下次自己准备阶段加入手卡”的延迟效果。
function c5237827.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍然存在且与效果相关，将其以表侧表示除外；若除外成功则继续处理后续效果。
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 下次的自己的准备阶段时把那张卡加入手卡。
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
-- 延迟效果的发动条件：当前回合玩家为自己，即自己的准备阶段。
function c5237827.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保只在下次自己的准备阶段处理。
	return Duel.GetTurnPlayer()==tp
end
-- 延迟效果处理：将被除外的装备魔法卡加入持有者手卡。
function c5237827.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被除外的那张装备魔法卡送去其持有者的手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
