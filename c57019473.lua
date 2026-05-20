--ONeサンダー
-- 效果：
-- 这张卡召唤成功时，可以选择「雷电姐姐」以外的自己墓地1只雷族·光属性·4星·攻击力1600以下的怪兽从游戏中除外。这个回合的结束阶段时那张卡加入手卡。
function c57019473.initial_effect(c)
	-- 这张卡召唤成功时，可以选择「雷电姐姐」以外的自己墓地1只雷族·光属性·4星·攻击力1600以下的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57019473,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c57019473.rmtg)
	e1:SetOperation(c57019473.rmop)
	c:RegisterEffect(e1)
end
-- 过滤条件：雷族、光属性、4星、卡名非「雷电姐姐」、攻击力1600以下且可以除外的怪兽
function c57019473.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
		and not c:IsCode(57019473) and c:IsAttackBelow(1600) and c:IsAbleToRemove()
end
-- 效果发动的目标选择与检测，确认墓地中是否存在符合条件的怪兽并进行取对象
function c57019473.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57019473.filter(chkc) end
	-- 在效果发动检测时，判断自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c57019473.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57019473.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示此效果包含除外操作并指定目标卡片
	Duel.SetOperationInfo(0,HINTMSG_REMOVE,g,1,0,0)  --"请选择要除外的卡"
end
-- 效果处理，将目标怪兽除外，并为该怪兽注册一个在结束阶段加入手卡的效果
function c57019473.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍与效果相关联，并将其表侧表示除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 这个回合的结束阶段时那张卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCountLimit(1)
		e1:SetOperation(c57019473.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 结束阶段将除外卡片加入手卡的效果处理
function c57019473.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡送回持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	-- 向对方玩家确认加入手卡的卡片
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
