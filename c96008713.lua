--マジックアーム・シールド
-- 效果：
-- ①：对方场上有表侧表示怪兽2只以上存在，自己场上有怪兽存在的场合，对方怪兽的攻击宣言时以攻击怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到战斗阶段结束时得到，攻击对象转移为那只怪兽进行伤害计算。
function c96008713.initial_effect(c)
	-- ①：对方场上有表侧表示怪兽2只以上存在，自己场上有怪兽存在的场合，对方怪兽的攻击宣言时以攻击怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到战斗阶段结束时得到，攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c96008713.condition)
	e1:SetTarget(c96008713.target)
	e1:SetOperation(c96008713.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件是否满足
function c96008713.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合（对方怪兽攻击宣言时），且自己场上存在怪兽
	return tp~=Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
-- 过滤条件：表侧表示且可以转移控制权的怪兽
function c96008713.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 发动时的对象选择与效果处理准备
function c96008713.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local atr=Duel.GetAttacker()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c96008713.filter(chkc) end
	-- 检查对方场上是否存在除攻击怪兽以外的、可以转移控制权的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c96008713.filter,tp,0,LOCATION_MZONE,1,atr) end
	-- 提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择除攻击怪兽以外的对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96008713.filter,tp,0,LOCATION_MZONE,1,1,atr)
	-- 设置效果分类为控制权转移，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数
function c96008713.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 若对象怪兽在效果处理时仍合法，则尝试直到战斗阶段结束时获得其控制权
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetControl(tc,tp,PHASE_BATTLE,1)~=0 then
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 使攻击怪兽与获得控制权的对象怪兽进行伤害计算
			Duel.CalculateDamage(a,tc)
		end
	end
end
