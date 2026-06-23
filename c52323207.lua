--番兵ゴーレム
-- 效果：
-- 这张卡1回合1次，可以变成里侧守备表示。这张卡反转召唤成功时，选择对方1只怪兽回到持有者手卡。
function c52323207.initial_effect(c)
	-- 这张卡1回合1次，可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52323207,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c52323207.target)
	e1:SetOperation(c52323207.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，选择对方1只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52323207,1))  --"返回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c52323207.thtg)
	e2:SetOperation(c52323207.thop)
	c:RegisterEffect(e2)
end
-- 检查是否可以将此卡变为里侧守备表示，并且此卡在本回合未发动过效果
function c52323207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(52323207)==0 end
	c:RegisterFlagEffect(52323207,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息为改变表示形式效果
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行将此卡变为里侧守备表示的操作
function c52323207.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 选择对方场上1只可以送入手牌的怪兽作为目标
function c52323207.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为送入手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行将目标怪兽送入对方手牌的操作
function c52323207.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入对方手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
