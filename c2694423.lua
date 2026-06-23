--メデューサ・ワーム
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。这张卡反转召唤成功时，对方场上1只怪兽破坏。
function c2694423.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2694423,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2694423.target)
	e1:SetOperation(c2694423.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2694423,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c2694423.destg)
	e2:SetOperation(c2694423.desop)
	c:RegisterEffect(e2)
end
-- 效果发动时判断是否可以变更为里侧守备表示且本回合未发动过此效果
function c2694423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(2694423)==0 end
	c:RegisterFlagEffect(2694423,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁操作信息为改变表示形式效果，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行将自身变为里侧守备表示的操作
function c2694423.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 选择对方场上1只怪兽作为破坏对象
function c2694423.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为破坏效果，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏选择的对方怪兽
function c2694423.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将目标怪兽以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
