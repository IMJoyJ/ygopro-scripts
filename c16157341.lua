--武神器－オハバリ
-- 效果：
-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c16157341.initial_effect(c)
	-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16157341,0))  --"贯穿附加"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16157341.condition)
	e1:SetCost(c16157341.cost)
	e1:SetTarget(c16157341.target)
	e1:SetOperation(c16157341.operation)
	c:RegisterEffect(e1)
end
-- 该条件函数判定效果的发动时机：我方处于主要阶段1且允许进入战斗阶段，满足“自己的主要阶段1”才能发动。
function c16157341.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否能够进入战斗阶段，作为该起动效果只能在主要阶段1发动的限制条件。
	return Duel.IsAbleToEnterBP()
end
-- 代价函数：确认这张卡在手牌且可以送去墓地作为代价；若可以则实际执行送墓，满足“把这张卡从手卡送去墓地”的发动代价。
function c16157341.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把作为发动代价的这张卡从手卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 对象过滤条件：选择自己场上表侧表示、名字带有「武神」且还未拥有贯穿效果的怪兽。
function c16157341.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 目标选择函数：在发动时从自己场上选择1只符合条件的「武神」怪兽作为效果对象，并检查该选择是否合法。
function c16157341.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16157341.filter(chkc) end
	-- 在发动时确认自己场上是否存在至少1只符合条件的对象，保证效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c16157341.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择对象的提示信息，提示玩家正在选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只符合条件的「武神」怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c16157341.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：对对象怪兽赋予贯穿效果，使其在本回合内攻击守备表示怪兽时造成贯穿战斗伤害。
function c16157341.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 对应效果原文“这个回合，选择的怪兽向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。”，即为对象怪兽附加贯穿伤害效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
