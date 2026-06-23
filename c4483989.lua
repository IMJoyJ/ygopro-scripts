--反撃準備
-- 效果：
-- 每次对方玩家对表侧守备表示怪兽进行攻击宣言时，投掷硬币猜正反。
-- ●猜中的场合：被攻击的表侧守备表示怪兽变成攻击表示。
-- ●猜错的场合：这张卡的控制者受到攻击怪兽的攻击力超过攻击对象的怪兽的守备力的数值的伤害。
function c4483989.initial_effect(c)
	-- 每次对方玩家对表侧守备表示怪兽进行攻击宣言时，投掷硬币猜正反。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetTarget(c4483989.atktg1)
	e1:SetOperation(c4483989.atkop)
	c:RegisterEffect(e1)
	-- 猜中的场合：被攻击的表侧守备表示怪兽变成攻击表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4483989,0))  --"猜硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c4483989.atkcon)
	e2:SetTarget(c4483989.atktg2)
	e2:SetOperation(c4483989.atkop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方玩家攻击表侧守备表示怪兽的攻击宣言时点
function c4483989.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	-- 判断是否为对方玩家攻击表侧守备表示怪兽的攻击宣言时点
	return tp~=Duel.GetTurnPlayer() and at and at:IsPosition(POS_FACEUP_DEFENSE)
end
-- 设置连锁处理时点为攻击宣言时，若满足条件则设置标签为1并建立效果关系
function c4483989.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	-- 检查是否为攻击宣言时点且攻击玩家不是当前回合玩家
	if Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and tp~=Duel.GetTurnPlayer()
		and at and at:IsPosition(POS_FACEUP_DEFENSE) then
		e:SetLabel(1)
		-- 建立攻击怪兽与效果的关系
		Duel.GetAttacker():CreateEffectRelation(e)
		at:CreateEffectRelation(e)
		-- 设置操作信息为投掷硬币
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	end
end
-- 设置连锁处理时点为攻击宣言时，若满足条件则设置标签为1并建立效果关系
function c4483989.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(1)
	-- 建立攻击怪兽与效果的关系
	Duel.GetAttacker():CreateEffectRelation(e)
	-- 建立被攻击怪兽与效果的关系
	Duel.GetAttackTarget():CreateEffectRelation(e)
	-- 设置操作信息为投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 处理攻击宣言时的连锁效果
function c4483989.atkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToEffect(e) and at:IsFaceup() and at:IsRelateToEffect(e) then
		-- 提示对方选择硬币正反面
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 对方玩家宣言硬币正反面
		local coin=Duel.AnnounceCoin(1-tp)
		-- 对方玩家投掷硬币
		local res=Duel.TossCoin(1-tp,1)
		if coin~=res then
			-- 若猜错则将被攻击怪兽变为攻击表示
			Duel.ChangePosition(at,POS_FACEUP_ATTACK)
		elseif a:GetAttack()>at:GetDefense() then
			-- 若猜错则对控制者造成伤害
			Duel.Damage(tp,a:GetAttack()-at:GetDefense(),REASON_EFFECT)
		end
	end
end
