--幻惑の眼
-- 效果：
-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合，可以从以下效果选择1个发动。
-- ●这个回合中，自己的幻想魔族·魔法师族怪兽不会被战斗破坏。
-- ●对方回合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
-- ●对方怪兽的攻击宣言时，以攻击怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
local s,id,o=GetID()
-- 定义幻惑之眼的效果初始化：创建并注册其①效果的发动入口，设置效果描述、类型（魔法发动）、发动时点、发动条件、发动时目标选择与处理函数。
function s.initial_effect(c)
	-- ①：自己场上有幻想魔族或魔法师族的怪兽存在的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：用于判断怪兽是否为表侧表示且种族为幻想魔族或魔法师族。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER)
end
-- 定义效果发动条件：检查自己场上是否存在至少1只表侧表示且为幻想魔族/魔法师族的怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若存在满足条件的怪兽，则发动条件成立。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果对象筛选函数：要求对象为表侧表示且控制权可以被改变。
function s.tfilter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 效果发动时的目标指定处理：先验证重新选择对象的合法性；随后判断各选项是否可选，弹出选项让玩家选择；根据选择设置效果类别与取对象属性，并为选项2/3选择对应对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽，用于选项3中排除攻击怪兽自身。
	local a=Duel.GetAttacker()
	if chkc then
		local f={false,s.tfilter(chkc),chkc:IsFaceup() and chkc~=a}
		return f[e:GetLabel()] and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
	end
	if chk==0 then return true end
	-- 选项2的可用条件之一：当前为对方回合。
	local b2=Duel.GetTurnPlayer()==1-tp
		-- 选项2的可用条件之二：对方场上有表侧表示且控制权可改变（可成为对象）的怪兽存在。
		and Duel.IsExistingTarget(s.tfilter,tp,0,LOCATION_MZONE,1,nil)
	-- 选项3的可用条件之一：当前为对方回合。
	local b3=Duel.GetTurnPlayer()==1-tp
		-- 选项3的可用条件之二：正处于对方怪兽攻击宣言的时点。
		and Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE)
		-- 选项3的可用条件之三：对方场上存在攻击怪兽以外的表侧表示怪兽，可作为攻击转移对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,a)
	local op=aux.SelectFromOptions(tp,{true,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)},{b3,aux.Stringid(id,3)})  --"不会被战斗破坏/得到控制权/攻击对象转移"
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
		e:SetProperty(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家显示选择要改变控制权的怪兽的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		-- 让玩家从对方场上选择1只满足条件的表侧怪兽，并将其设为效果对象。
		local g=Duel.SelectTarget(tp,s.tfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 将连锁操作信息设置为‘获得控制权’，指定对象为g、数量为1，供后续连锁反应检测。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家显示选择效果对象的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家选择1只对方场上表侧表示且不是攻击怪兽的怪兽，作为攻击对象转移的目标。
		Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,a)
	end
end
-- 效果处理入口：根据发动时选择的选项（记录在Label中），分别调用保护、获得控制权或攻击转移的处理函数。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.protect(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.control(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.tattack(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 选项1的处理：为控制者场上所有幻想魔族/魔法师族怪兽附加直到结束阶段不会被战斗破坏的效果。
function s.protect(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己的幻想魔族·魔法师族怪兽不会被战斗破坏。对方回合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。对方怪兽的攻击宣言时，以攻击怪兽以外的对方场上1只表侧表示怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 保护效果的适用对象限定为幻想魔族或魔法师族的怪兽（通过TargetBoolFunction生成目标判断函数）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ILLUSION+RACE_SPELLCASTER))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将上述保护效果注册到tp方场上，持续到结束阶段（由Reset控制）。
	Duel.RegisterEffect(e1,tp)
end
-- 选项2的处理：若效果对象仍与效果相关联，则获得其控制权直到结束阶段。
function s.control(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽（要夺取控制权的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联后，令tp方从当前控制者手中获得其控制权，持续到结束阶段（PHASE_END,1）。
	if tc and tc:IsRelateToEffect(e) then Duel.GetControl(tc,tp,PHASE_END,1) end
end
-- 选项3的处理：确认攻击怪兽仍可攻击且不免疫此效果，且对象仍关联，则强制其与所选对象进行伤害计算，实现攻击对象转移。
function s.tattack(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	-- 获取发动时选择的对象怪兽（攻击转移的目标）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 令攻击怪兽a与对象tc进行伤害计算，完成攻击对象转移。
		Duel.CalculateDamage(a,tc)
	end
end
