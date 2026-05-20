--サーチ・ストライカー
-- 效果：
-- 这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。这个效果发动的场合，这张卡在战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
function c80885324.initial_effect(c)
	-- 这张卡向里侧守备表示怪兽攻击的场合，可以不进行伤害计算以里侧守备表示的状态把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80885324,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(c80885324.descon)
	e1:SetTarget(c80885324.destg)
	e1:SetOperation(c80885324.desop)
	c:RegisterEffect(e1)
	-- 这个效果发动的场合，这张卡在战斗阶段结束时变成守备表示，直到下次的自己回合的结束阶段时不能把表示形式改变。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c80885324.poscon)
	e2:SetOperation(c80885324.posop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件：自身进行攻击，且攻击目标是里侧守备表示怪兽
function c80885324.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 确认自身是攻击怪兽，且攻击目标存在、为里侧表示、为守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsFacedown() and d:IsDefensePos()
end
-- 效果发动的目标确认与操作信息设置
function c80885324.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为破坏1只攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理：若攻击目标仍在战斗中，则将其破坏，并给自身添加已发动效果的标记
function c80885324.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 因效果破坏攻击目标怪兽
		Duel.Destroy(d,REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(80885324,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否满足改变表示形式的条件：自身带有已发动效果的标记
function c80885324.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(80885324)~=0
end
-- 战斗阶段结束时的效果处理：将自身变为守备表示，并施加不能改变表示形式的限制
function c80885324.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将自身变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合的结束阶段时不能把表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
