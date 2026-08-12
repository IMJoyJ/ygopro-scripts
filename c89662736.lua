--武神器－ヤタ
-- 效果：
-- 自己场上的名字带有「武神」的兽战士族怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡送去墓地才能发动。攻击怪兽的攻击无效，给与对方基本分那只怪兽的攻击力一半数值的伤害。「武神器-八咫」的效果1回合只能使用1次。
function c89662736.initial_effect(c)
	-- 自己场上的名字带有「武神」的兽战士族怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡送去墓地才能发动。攻击怪兽的攻击无效，给与对方基本分那只怪兽的攻击力一半数值的伤害。「武神器-八咫」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89662736,0))  --"攻击无效"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89662736)
	e1:SetCondition(c89662736.nacon)
	e1:SetCost(c89662736.nacost)
	e1:SetTarget(c89662736.natg)
	e1:SetOperation(c89662736.naop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上的表侧表示「武神」兽战士族怪兽被选择作为攻击对象
function c89662736.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x88) and at:IsRace(RACE_BEASTWARRIOR)
end
-- 检查并执行发动代价：将手牌中的这张卡送去墓地
function c89662736.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检查效果目标并设置操作信息：确认攻击怪兽在场，并预设给与对方伤害的操作信息
function c89662736.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时攻击怪兽是否仍在场上
	if chk==0 then return Duel.GetAttacker():IsOnField() end
	-- 计算攻击怪兽攻击力一半的数值
	local dam=math.floor(Duel.GetAttacker():GetAttack()/2)
	-- 设置效果处理信息为给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：无效攻击，并给与对方攻击怪兽攻击力一半数值的伤害
function c89662736.naop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击的怪兽
	local a=Duel.GetAttacker()
	-- 尝试无效该攻击，若成功则继续处理
	if Duel.NegateAttack() then
		-- 给与对方基本分该怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,math.floor(a:GetAttack()/2),REASON_EFFECT)
	end
end
