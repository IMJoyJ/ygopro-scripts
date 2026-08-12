--EMスパイク・イーグル
-- 效果：
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c22091345.initial_effect(c)
	-- 创建效果e1，设置为起动效果，适用区域为主怪兽区，具有取对象属性，一回合只能发动一次，条件为可以进入战斗阶段，目标为己方场上表侧表示的怪兽，效果处理为使目标怪兽获得贯穿伤害效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22091345,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c22091345.condition)
	e1:SetTarget(c22091345.target)
	e1:SetOperation(c22091345.operation)
	c:RegisterEffect(e1)
end
-- 检查回合玩家能否进入战斗阶段
function c22091345.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤函数，筛选出表侧表示且未受到贯穿伤害效果影响的怪兽
function c22091345.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 设置效果目标，当chkc不为空时返回是否为己方主怪兽区表侧表示的怪兽，当chk为0时检查是否存在满足条件的怪兽，若存在则提示选择表侧表示的怪兽并选择目标
function c22091345.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查是否存在满足条件的己方主怪兽区表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c22091345.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个满足条件的己方主怪兽区表侧表示的怪兽作为目标
	Duel.SelectTarget(tp,c22091345.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，获取目标怪兽，若目标怪兽仍然有效，则给目标怪兽添加贯穿伤害效果
function c22091345.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给目标怪兽添加贯穿伤害效果，该效果在结束阶段重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
