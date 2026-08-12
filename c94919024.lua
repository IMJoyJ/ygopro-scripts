--月光紅狐
-- 效果：
-- ①：这张卡被效果送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
-- ②：自己场上的「月光」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效，双方玩家回复1000基本分。
function c94919024.initial_effect(c)
	-- ①：这张卡被效果送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94919024,0))  --"特殊召唤的怪兽全部破坏"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c94919024.atkcon)
	e1:SetTarget(c94919024.atktg)
	e1:SetOperation(c94919024.atkop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「月光」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效，双方玩家回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94919024,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCondition(c94919024.condition)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c94919024.target)
	e2:SetOperation(c94919024.operation)
	c:RegisterEffect(e2)
end
-- 判定这张卡是否因效果被送去墓地
function c94919024.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果①的发动准备与对象选择，确认对方场上是否存在可以成为对象的表侧表示且攻击力不为0的怪兽
function c94919024.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定已选择的对象是否仍是对方场上表侧表示且攻击力不为0的怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 判定对方场上是否存在至少1只表侧表示且攻击力不为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示且攻击力不为0的怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理，将作为对象的怪兽的攻击力直到回合结束时变成0
function c94919024.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤出自己场上表侧表示的「月光」怪兽
function c94919024.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsSetCard(0xdf)
end
-- 判定是否发动了以自己场上表侧表示的「月光」怪兽为对象的效果，且该发动可以被无效
function c94919024.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为效果对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c94919024.filter,1,nil,tp)
		-- 判定该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果②的发动准备，设置将该连锁的发动无效的操作信息
function c94919024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在效果处理时将要使该发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的效果处理，使该发动无效，并让双方玩家回复1000基本分
function c94919024.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，若成功则执行后续处理
	if Duel.NegateActivation(ev) then
		-- 使自己回复1000基本分
		Duel.Recover(tp,1000,REASON_EFFECT)
		-- 使对方回复1000基本分
		Duel.Recover(1-tp,1000,REASON_EFFECT)
	end
end
