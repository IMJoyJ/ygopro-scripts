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
-- 设置控制权转移效果的处理目标为自身
function c52702748.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 控制权转移效果的执行函数，将自身控制权转移给对方
function c52702748.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将自身控制权转移给对方玩家
	Duel.GetControl(c,1-tp)
end
-- 设置每次结束阶段除外效果的处理目标为己方墓地可除外的卡
function c52702748.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove(1-tp) end
	-- 检查己方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil,1-tp) end
	-- 向对方玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方玩家墓地中一张可除外的卡作为目标
	local g=Duel.SelectTarget(1-tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil,1-tp)
	-- 设置操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 除外效果的执行函数，将选中的卡从游戏中除外
function c52702748.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
