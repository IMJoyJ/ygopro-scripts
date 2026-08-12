--空炎星－サイチョウ
-- 效果：
-- 自己场上的名字带有「炎星」的怪兽进行战斗的伤害计算时只有1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡和手卡1只名字带有「炎星」的怪兽送去墓地才能发动。进行战斗的自己怪兽的攻击力只在那次伤害计算时上升送去墓地的怪兽的原本攻击力数值。
function c66084673.initial_effect(c)
	-- 自己场上的名字带有「炎星」的怪兽进行战斗的伤害计算时只有1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡和手卡1只名字带有「炎星」的怪兽送去墓地才能发动。进行战斗的自己怪兽的攻击力只在那次伤害计算时上升送去墓地的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66084673,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c66084673.atkcon)
	e1:SetCost(c66084673.atkcost)
	e1:SetOperation(c66084673.atkop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，判断是否满足「自己场上的名字带有『炎星』的怪兽进行战斗的伤害计算时」的时点
function c66084673.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由自己控制且是名字带有「炎星」的怪兽
	return (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsSetCard(0x79))
		-- 或者检查被攻击怪兽存在、由自己控制且是名字带有「炎星」的怪兽
		or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsSetCard(0x79))
end
-- 定义过滤函数1：自己场上表侧表示、可以作为代价送去墓地的名字带有「炎舞」的魔法·陷阱卡
function c66084673.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsAbleToGraveAsCost()
end
-- 定义过滤函数2：手牌中可以作为代价送去墓地、且原本攻击力大于0的名字带有「炎星」的怪兽
function c66084673.filter2(c)
	return c:IsSetCard(0x79) and c:GetBaseAttack()>0 and c:IsAbleToGraveAsCost()
end
-- 定义发动代价函数：检查是否已发动过该效果，以及场上和手牌是否存在满足代价条件的卡片
function c66084673.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(66084673)==0
		-- 检查自己场上是否存在至少1张满足过滤条件1的「炎舞」卡片
		and Duel.IsExistingMatchingCard(c66084673.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己手牌中是否存在至少1张满足过滤条件2的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c66084673.filter2,tp,LOCATION_HAND,0,1,nil) end
	-- 设置选择卡片时的提示信息为“送去墓地”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足过滤条件1的「炎舞」卡片
	local g1=Duel.SelectMatchingCard(tp,c66084673.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 再次设置选择卡片时的提示信息为“送去墓地”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择1张满足过滤条件2的「炎星」怪兽
	local g2=Duel.SelectMatchingCard(tp,c66084673.filter2,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabel(g2:GetFirst():GetBaseAttack())
	g1:Merge(g2)
	-- 将选中的卡片（包含场上的「炎舞」和手牌的「炎星」）作为发动代价送去墓地
	Duel.SendtoGrave(g1,REASON_COST)
	e:GetHandler():RegisterFlagEffect(66084673,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 定义效果处理函数：使进行战斗的自己怪兽的攻击力只在那次伤害计算时上升送去墓地的怪兽的原本攻击力数值
function c66084673.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local c=Duel.GetAttacker()
	-- 如果攻击怪兽是对方控制的，则将目标怪兽指向被攻击的怪兽（即自己场上的怪兽）
	if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
	-- 进行战斗的自己怪兽的攻击力只在那次伤害计算时上升送去墓地的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
end
