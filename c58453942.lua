--サイコ・ウォールド
-- 效果：
-- 支付800基本分发动。自己场上表侧表示存在的1只念动力族怪兽在同1次的战斗阶段中可以作2次攻击。这个效果发动的回合这张卡不能攻击。
function c58453942.initial_effect(c)
	-- 支付800基本分发动。自己场上表侧表示存在的1只念动力族怪兽在同1次的战斗阶段中可以作2次攻击。这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58453942,0))  --"多次攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c58453942.condition)
	e1:SetCost(c58453942.cost)
	e1:SetTarget(c58453942.target)
	e1:SetOperation(c58453942.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查当前回合玩家是否能进入战斗阶段
function c58453942.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 定义Cost函数：支付800基本分，并使自身本回合不能攻击
function c58453942.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0（检查是否能发动）时，检查玩家是否能支付800基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 扣除玩家800基本分
	Duel.PayLPCost(tp,800)
	-- 这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤函数：自己场上表侧表示、且未获得追加攻击效果的念动力族怪兽
function c58453942.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0
end
-- 定义Target函数：选择自己场上1只表侧表示的念动力族怪兽（排除自身）作为效果对象
function c58453942.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c58453942.filter(chkc) end
	-- 在chk为0时，检查场上是否存在符合条件的念动力族怪兽（排除自身）
	if chk==0 then return Duel.IsExistingTarget(c58453942.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的念动力族怪兽（排除自身）作为效果对象
	Duel.SelectTarget(tp,c58453942.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 定义Operation函数：使目标怪兽在同一次战斗阶段中可以作2次攻击
function c58453942.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) then
		-- 在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
