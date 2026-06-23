--死者への供物
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽破坏。下次的自己抽卡阶段跳过。
function c19230407.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19230407.target)
	e1:SetOperation(c19230407.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：怪兽必须表侧表示
function c19230407.filter(c)
	return c:IsFaceup()
end
-- 效果处理时选择目标：选择场上1只表侧表示怪兽
function c19230407.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19230407.filter(chkc) end
	-- 检查是否满足发动条件：场上是否存在1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c19230407.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19230407.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息：将选择的怪兽设为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时执行的操作：破坏对象怪兽并跳过下次抽卡阶段
function c19230407.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
	-- 下次的自己抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetTargetRange(1,0)
	-- 判断是否在自己的抽卡阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	end
	-- 注册跳过抽卡阶段的效果
	Duel.RegisterEffect(e1,tp)
end
