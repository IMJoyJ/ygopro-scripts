--オーバー・デッド・ライン
-- 效果：
-- 只要这张卡在场上存在，从墓地在自己场上特殊召唤的植物族怪兽的攻击力上升1000。这张卡在发动后第2次的自己的结束阶段时破坏。
function c87046457.initial_effect(c)
	-- 这张卡在发动后第2次的自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c87046457.acttg)
	c:RegisterEffect(e1)
	-- 从墓地在自己场上特殊召唤的植物族怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87046457,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c87046457.target)
	e2:SetOperation(c87046457.operation)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，从墓地在自己场上特殊召唤的植物族怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c87046457.atkcon)
	e3:SetTarget(c87046457.atktg)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	e3:SetLabelObject(g)
end
-- 卡片发动时的效果处理：注册在发动后第2次自己的结束阶段时将自身破坏的效果，并初始化回合计数器
function c87046457.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡在发动后第2次的自己的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c87046457.descon)
	e1:SetOperation(c87046457.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
-- 判断是否在自己的结束阶段触发效果
function c87046457.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 在结束阶段累加回合计数器，并在达到第2次时将这张卡破坏
function c87046457.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 因卡片效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤出在自己场上表侧表示存在、且从墓地特殊召唤的植物族怪兽
function c87046457.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE) and (not e or c:IsRelateToEffect(e))
end
-- 检查特殊召唤的怪兽中是否存在符合条件的植物族怪兽，并将其设为效果处理的对象
function c87046457.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c87046457.filter,1,nil,nil,tp) end
	-- 将特殊召唤成功的怪兽组设置为当前效果的处理对象
	Duel.SetTargetCard(eg)
end
-- 筛选出符合条件的怪兽，为其注册标记并加入到攻击力上升的记录卡组中
function c87046457.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atkg=e:GetLabelObject()
	if c:GetFlagEffect(87046457)==0 then
		c:RegisterFlagEffect(87046457,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
		atkg:Clear()
	end
	local g=eg:Filter(c87046457.filter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(87046457,RESET_EVENT+RESETS_STANDARD,0,1)
		atkg:AddCard(tc)
		tc=g:GetNext()
	end
end
-- 判断这张卡是否已成功发动并存在于场上
function c87046457.atkcon(e)
	return e:GetHandler():GetFlagEffect(87046457)~=0
end
-- 判断目标怪兽是否在记录的卡片组中且带有标记，以适用攻击力上升效果
function c87046457.atktg(e,c)
	return e:GetLabelObject():IsContains(c) and c:GetFlagEffect(87046457)~=0
end
