--パラレル・セレクト
-- 效果：
-- 自己场上存在的同调怪兽被对方破坏送去墓地时，选择从游戏中除外的1张自己的魔法卡发动。选择的魔法卡加入手卡。
function c23327298.initial_effect(c)
	-- 自己场上存在的同调怪兽被对方破坏送去墓地时，选择从游戏中除外的1张自己的魔法卡发动。选择的魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c23327298.condition)
	e1:SetTarget(c23327298.target)
	e1:SetOperation(c23327298.operation)
	c:RegisterEffect(e1)
end
-- 筛选被送去墓地的卡：必须是同调怪兽，之前在我方场上表侧表示，原先控制者是我方，且破坏原因为对方（1-tp）的效果或战斗等导致。
function c23327298.cfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsControler(tp) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 检查本次送去墓地的怪兽群中是否存在至少1张满足“自己场上的同调怪兽被对方破坏送去墓地”这一条件的卡，满足则效果可以发动。
function c23327298.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23327298.cfilter,1,nil,tp)
end
-- 筛选可选为对象的卡：必须是从游戏中除外的表侧表示魔法卡，并且能够加入手卡。
function c23327298.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动的目标处理：指定自己除外区的1张表侧表示魔法卡为对象，并设置回手牌的操作信息。
function c23327298.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c23327298.filter(chkc) end
	-- 效果发动时检查自己除外区是否存在至少1张符合条件的表侧魔法卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c23327298.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 弹出选择提示，告知玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己除外区的表侧魔法卡中选择1张作为效果对象，并将其登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c23327298.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置本次效果处理包含“返回手牌”的操作信息，对象为已选择的卡，数量为选中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时，取得选择的卡；若该卡仍与效果关联，则将其加入手牌，并向对方展示。
function c23327298.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中作为效果对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认已加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
