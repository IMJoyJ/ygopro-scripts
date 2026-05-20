--パワー・ブレイカー
-- 效果：
-- 这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地时，选择对方场上表侧表示存在的1张魔法·陷阱卡破坏。这张卡攻击的场合，伤害步骤结束时变成守备表示。
function c6903857.initial_effect(c)
	-- 这张卡被对方怪兽的攻击或者对方的效果破坏送去墓地时，选择对方场上表侧表示存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6903857,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c6903857.condition)
	e1:SetTarget(c6903857.target)
	e1:SetOperation(c6903857.operation)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，伤害步骤结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6903857,1))  --"变成守备表示"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c6903857.poscon)
	e2:SetOperation(c6903857.posop)
	c:RegisterEffect(e2)
end
-- 判定是否满足“被对方怪兽的攻击或者对方的效果破坏送去墓地时”的发动条件
function c6903857.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		-- 判定是否是被对方的效果破坏（由对方玩家操作），或者是在战斗中作为攻击对象被破坏
		and (c:IsReason(REASON_DESTROY) and rp==1-tp or c:IsReason(REASON_BATTLE) and c==Duel.GetAttackTarget())
end
-- 过滤条件：表侧表示的魔法·陷阱卡
function c6903857.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的靶向选择（Target）处理
function c6903857.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c6903857.dfilter(chkc) end
	if chk==0 then return true end
	-- 在客户端提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示的1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c6903857.dfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，声明此效果包含破坏操作，并注册目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际运行（Operation）处理
function c6903857.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第1个效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定是否满足“这张卡攻击的场合，伤害步骤结束时”的发动条件
function c6903857.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自身是否是攻击怪兽，且在伤害步骤结束时仍处于战斗关联状态
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end
-- 变更表示形式效果的实际运行（Operation）处理
function c6903857.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() and c:IsRelateToBattle() then
		-- 将自身变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
