--幻影の妖精
-- 效果：
-- 这张卡受到从对方怪兽来的攻击的场合，让其他的自己场上1只怪兽承受攻击，进行伤害计算。
function c8687195.initial_effect(c)
	-- 这张卡受到从对方怪兽来的攻击的场合，让其他的自己场上1只怪兽承受攻击，进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8687195,0))  --"代替战斗"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(c8687195.condition)
	e1:SetTarget(c8687195.target)
	e1:SetOperation(c8687195.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件
function c8687195.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断被攻击的怪兽是否是自身，且攻击怪兽是否由对方控制
	return Duel.GetAttackTarget()==e:GetHandler() and Duel.GetAttacker():IsControler(1-tp)
end
-- 定义效果的目标选择（Target）
function c8687195.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc~=e:GetHandler() end
	if chk==0 then return true end
	-- 在客户端显示提示信息，要求玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上除这张卡以外的1只怪兽作为效果的对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 定义效果的处理（Operation）
function c8687195.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	if tc and tc:IsRelateToEffect(e) and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 令攻击怪兽与选择的自己怪兽进行战斗伤害计算
		Duel.CalculateDamage(a,tc)
	end
end
