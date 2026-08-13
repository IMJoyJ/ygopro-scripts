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
-- 起动效果的发动条件与一回合一次限制检查：当自身可以变成里侧守备表示且本回合尚未使用过该效果时，允许发动，并注册一个直到结束阶段前有效的1回合1次使用标识，同时设置后续将改变表示形式的操作信息。
function c52323207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(52323207)==0 end
	c:RegisterFlagEffect(52323207,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置本连锁将进行“改变表示形式”的操作信息，对象为这张卡，数量为1，供相关效果检测或连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时的实际操作：若这张卡仍与效果相关且处于表侧表示，则将其变成里侧守备表示。
function c52323207.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转召唤成功时的诱发效果的目标处理：选择对方场上1只怪兽作为对象，要求其可以加入手卡；选择后设置将送回手卡的操作信息。
function c52323207.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向操作玩家显示选择提示，提示文字为“请选择要返回手卡的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让操作玩家从对方场上选择1只满足可以加入手卡的怪兽，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁将进行“返回手卡”的操作信息，目标为已选择的怪兽，数量为其张数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的实际操作：取出效果对象，若该对象仍与效果相关，则将其送回持有者手卡。
function c52323207.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
