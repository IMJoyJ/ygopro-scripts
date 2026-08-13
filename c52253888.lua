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
-- 效果①的发动条件：当前回合玩家不是此卡的控制者（即对方回合），且处于战斗阶段开始时，才允许发动。
function c52253888.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家不是此卡的控制者tp，即满足“对方战斗阶段开始时”中的对方回合条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①取对象处理：先校验连锁对象为对方场上的攻击表示怪兽，再检查是否存在至少1只可选对象，然后提示玩家选择1~7只对方场上的攻击表示怪兽作为本效果的对象。
function c52253888.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttackPos() end
	-- 发动合法性检查：确认对方场上有至少1只攻击表示怪兽可以作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示，提示内容为“请选择攻击表示的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)  --"请选择攻击表示的怪兽"
	-- 让当前玩家从对方场上选择1~7只攻击表示怪兽，并将这些怪兽登记为本连锁的对象。
	Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,7,nil)
end
-- 效果①处理：先确认此卡仍在自己怪兽区域且与效果相关，再取出仍有效的对象；对每个对象建立与此卡的关联，并赋予其“必须攻击”和“必须攻击此卡”的效果，持续到结束阶段。
function c52253888.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp)) then return end
	-- 从连锁信息中取得本效果的对象群，并筛选出仍然与本效果有关联的对象（未离场、仍可受影响）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 只要这张卡在自己的怪兽区域存在，这个回合，作为对象的怪兽可以攻击的场合，必须向这张卡作出攻击。
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
-- 判定效果所有者（光之法理灵媒）是否仍与被附加“必须攻击”效果的怪兽保持关联；只有关联成立（此卡仍在场）时，该怪兽才被强制攻击。
function c52253888.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetOwner():IsRelateToCard(e:GetHandler())
end
-- 指定“必须攻击”的目标：当攻击对象c等于效果所有者（光之法理灵媒）时返回true，从而强制对象怪兽只能向此卡攻击。
function c52253888.atklimit(e,c)
	return c==e:GetOwner()
end
-- 效果②的发动条件：此卡与对方表侧攻击表示怪兽进行战斗的攻击宣言（攻击者或攻击目标包含此卡），且战斗对象是对方表侧攻击表示怪兽。
function c52253888.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 确认战斗对象bc存在、为表侧攻击表示，且此卡是攻击方或攻击目标，满足“这张卡和对方的攻击表示怪兽进行战斗”。
	return bc and bc:IsPosition(POS_FACEUP_ATTACK) and (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 效果②发动时：无需取对象，计算战斗对象原本攻击力的一半（向上取整）作为预定伤害，并登记到连锁信息中。
function c52253888.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=math.ceil(e:GetHandler():GetBattleTarget():GetBaseAttack()/2)
	-- 登记连锁操作信息：本效果将给与对方玩家dam点效果伤害，供后续伤害相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②处理时：先无效那次攻击；无效成功且战斗对象仍存在并由对方控制时，给与对方其原本攻击力一半数值的伤害。
function c52253888.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 执行无效攻击，并检查无效是否成功、战斗对象是否仍与战斗相关且为对方控制，满足条件才继续造成伤害。
	if Duel.NegateAttack() and bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 给予对方玩家1-tp伤害，伤害值为对方战斗怪兽原本攻击力的一半（向上取整），伤害原因为效果。
		Duel.Damage(1-tp,math.ceil(bc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
