--異次元への案内人
-- 效果：
-- 这张卡召唤成功时，这张卡的控制权转移给对方。每次结束阶段，对方选择这张卡的控制者的墓地里的1张卡从游戏中除外。
function c52702748.initial_effect(c)
	-- 这张卡召唤成功时，这张卡的控制权转移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52702748,0))  --"控制权转移"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c52702748.ctltg)
	e1:SetOperation(c52702748.ctlop)
	c:RegisterEffect(e1)
	-- 每次结束阶段，对方选择这张卡的控制者的墓地里的1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52702748,1))  --"除外"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c52702748.rmtg)
	e2:SetOperation(c52702748.rmop)
	c:RegisterEffect(e2)
end
-- 发动控制权转移效果的必发触发判定：无额外发动条件，并在发动时把本卡自身作为控制权变更的对象信息登记。
function c52702748.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁的效果分类为改变控制权（CATEGORY_CONTROL），对象为效果持有者自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 处理控制权转移：若这张卡仍与效果相关且不是里侧表示，则将其控制权转移给对方。
function c52702748.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 执行控制权转移操作：让这张卡归对方（当前控制者的对手）控制。
	Duel.GetControl(c,1-tp)
end
-- 除外效果的发动条件与取对象处理：检查控制者墓地是否有可除外的卡；若存在，则由对方从当前控制者的墓地选择1张卡作为对象，并登记除外操作信息。
function c52702748.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove(1-tp) end
	-- 发动条件判定：检查当前控制者的墓地是否存在至少1张能被对方除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil,1-tp) end
	-- 向选择方（对方）发送提示消息，显示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由对方从当前控制者的墓地选择1张能被对方除外的卡作为效果对象，并自动使其与效果建立联系。
	local g=Duel.SelectTarget(1-tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil,1-tp)
	-- 设置操作信息：效果分类为除外（CATEGORY_REMOVE），对象为所选墓地卡，数量1，对象持有者为当前控制者，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 处理除外效果：取得连锁的对象卡，若它仍与效果相关，则将其除外。
function c52702748.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的连锁对象卡（被选择的那张墓地卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将被选择的那张卡以表侧表示、效果原因从墓地除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
