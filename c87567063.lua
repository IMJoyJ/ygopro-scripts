--造反劇
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的战斗阶段以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到战斗阶段结束时得到。这个回合，作为对象的怪兽以外的自己怪兽不能攻击。
function c87567063.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的战斗阶段以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到战斗阶段结束时得到。这个回合，作为对象的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87567063+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c87567063.condition)
	e1:SetTarget(c87567063.target)
	e1:SetOperation(c87567063.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数
function c87567063.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否处于战斗阶段（从战斗阶段开始到结束）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果发动时的对象选择与信息注册函数
function c87567063.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 判定对方场上是否存在可以转移控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可以转移控制权的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为转移控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数
function c87567063.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到该怪兽的控制权，直到战斗阶段结束
		Duel.GetControl(tc,tp,PHASE_BATTLE,1)
	end
	-- 这个回合，作为对象的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c87567063.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制攻击的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤出除作为对象的怪兽以外的怪兽
function c87567063.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
