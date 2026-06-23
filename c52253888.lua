--ライトローミディアム
-- 效果：
-- ①：对方战斗阶段开始时，以对方场上的攻击表示怪兽任意数量为对象才能发动。只要这张卡在自己的怪兽区域存在，这个回合，作为对象的怪兽可以攻击的场合，必须向这张卡作出攻击。
-- ②：1回合1次，这张卡和对方的攻击表示怪兽进行战斗的攻击宣言时才能发动。那次攻击无效，给与对方那只对方怪兽的原本攻击力一半数值的伤害。
function c52253888.initial_effect(c)
	-- ①：对方战斗阶段开始时，以对方场上的攻击表示怪兽任意数量为对象才能发动。只要这张卡在自己的怪兽区域存在，这个回合，作为对象的怪兽可以攻击的场合，必须向这张卡作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52253888,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c52253888.atkcon1)
	e1:SetTarget(c52253888.atktg)
	e1:SetOperation(c52253888.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡和对方的攻击表示怪兽进行战斗的攻击宣言时才能发动。那次攻击无效，给与对方那只对方怪兽的原本攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52253888,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c52253888.damcon)
	e2:SetTarget(c52253888.damtg)
	e2:SetOperation(c52253888.damop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方的战斗阶段开始
function c52253888.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方的战斗阶段开始
	return Duel.GetTurnPlayer()~=tp
end
-- 选择对方场上的攻击表示怪兽作为对象
function c52253888.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttackPos() end
	-- 确认是否有对方场上的攻击表示怪兽可选
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)  --"请选择攻击表示的怪兽"
	-- 选择对方场上的攻击表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,7,nil)
end
-- 设置效果处理，使被选中的怪兽必须向此卡攻击
function c52253888.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp)) then return end
	-- 获取连锁中被选择的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 创建一个必须攻击的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetCondition(c52253888.atkcon2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e2:SetValue(c52253888.atklimit)
		tc:RegisterEffect(e2)
		tc=tg:GetNext()
	end
end
-- 判断此卡是否与效果相关联
function c52253888.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetOwner():IsRelateToCard(e:GetHandler())
end
-- 设定必须攻击的限制条件为只能攻击此卡
function c52253888.atklimit(e,c)
	return c==e:GetOwner()
end
-- 判断是否满足发动②效果的条件
function c52253888.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断对方怪兽是否处于攻击表示且当前攻击或被攻击
	return bc and bc:IsPosition(POS_FACEUP_ATTACK) and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 设置伤害效果的目标和数值
function c52253888.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.ceil(e:GetHandler():GetBattleTarget():GetBaseAttack()/2)
	-- 设置操作信息，准备造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行②效果的处理，无效攻击并造成伤害
function c52253888.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 确认攻击被成功无效且目标怪兽有效存在
	if Duel.NegateAttack() and bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 对对方玩家造成其怪兽原本攻击力一半的伤害
		Duel.Damage(1-tp,math.ceil(bc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
