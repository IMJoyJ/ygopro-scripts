--妖仙獣 閻魔巳裂
-- 效果：
-- ①：这张卡和风属性以外的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
-- ②：这张卡灵摆召唤成功时，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c39853199.initial_effect(c)
	-- ①：这张卡和风属性以外的表侧表示怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39853199,0))  --"破坏怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c39853199.destg1)
	e1:SetOperation(c39853199.desop1)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功时，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39853199,1))  --"破坏1张卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c39853199.descon2)
	e2:SetTarget(c39853199.destg2)
	e2:SetOperation(c39853199.desop2)
	c:RegisterEffect(e2)
	-- ③：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39853199,2))  --"返回手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c39853199.retcon)
	e3:SetTarget(c39853199.rettg)
	e3:SetOperation(c39853199.retop)
	c:RegisterEffect(e3)
	if not c39853199.global_check then
		c39853199.global_check=true
		-- 处理“这张卡召唤的回合”的效果(混沌幻影复制这种效果即使是这个回合召唤的也不能生效)
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(39853199)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 将效果注册给全局环境
		ge1:SetOperation(aux.sumreg)
		-- 效果作用：检索满足条件的卡片组
		Duel.RegisterEffect(ge1,0)
	end
end
-- 效果作用：将目标怪兽特殊召唤
function c39853199.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsNonAttribute(ATTRIBUTE_WIND) end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果作用：检索满足条件的卡片组
function c39853199.desop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 以reason原因破坏targets去dest，返回值是实际被破坏的数量
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果作用：将目标怪兽特殊召唤
function c39853199.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 效果作用：检索满足条件的卡片组
function c39853199.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 基本同Duel.IsExistingMatchingCard ，不同之处在于需要追加判定卡片是否能成为当前正在处理的效果的对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家player发送hint_type类型的消息提示，提示内容为desc
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 基本同Duel.SelectMatchingCard ，不同之处在于此函数会同时将当前正在处理的连锁的对象设置成选择的卡
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：检索满足条件的卡片组
function c39853199.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前连锁的所有的对象卡，一般只有一个对象时使用
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以reason原因破坏targets去dest，返回值是实际被破坏的数量
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果作用：将目标怪兽特殊召唤
function c39853199.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39853199)~=0
end
-- 效果作用：检索满足条件的卡片组
function c39853199.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果作用：将目标怪兽特殊召唤
function c39853199.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以reason原因把targets送去玩家player的手卡，返回值是实际被操作的数量
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
