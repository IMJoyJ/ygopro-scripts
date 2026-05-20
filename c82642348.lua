--クルーエル
-- 效果：
-- 这张卡被战斗破坏送去墓地时，投掷1个硬币猜正反。猜中的场合破坏对方1只怪兽。
function c82642348.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，投掷1个硬币猜正反。猜中的场合破坏对方1只怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82642348,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c82642348.descon)
	e1:SetTarget(c82642348.destg)
	e1:SetOperation(c82642348.desop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身是否因战斗破坏被送去墓地。
function c82642348.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义效果的目标选择处理：选择对方场上1只怪兽作为对象，并设置投掷硬币的操作信息。
function c82642348.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示此效果包含投掷1次硬币的处理。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 定义效果的运行处理：玩家猜测硬币正反并投掷硬币，若猜中则破坏作为对象的怪兽。
function c82642348.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面（进行猜测）。
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次硬币投掷。
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 因效果破坏目标怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
