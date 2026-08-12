--武神器－オロチ
-- 效果：
-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。
function c94096616.initial_effect(c)
	-- 自己的主要阶段1，把这张卡从手卡送去墓地，选择自己场上1只名字带有「武神」的怪兽才能发动。这个回合，选择的怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94096616,0))  --"直接攻击"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c94096616.condition)
	e1:SetCost(c94096616.cost)
	e1:SetTarget(c94096616.target)
	e1:SetOperation(c94096616.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定当前是否为主要阶段1
function c94096616.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能进入战斗阶段（以此判定当前是否为主要阶段1）
	return Duel.IsAbleToEnterBP()
end
-- 效果发动代价：将手牌中的这张卡送去墓地
function c94096616.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示、名字带有「武神」且未具有直接攻击效果的怪兽
function c94096616.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果发动目标：选择自己场上1只表侧表示的「武神」怪兽
function c94096616.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94096616.filter(chkc) end
	-- 检查自己场上是否存在符合条件的「武神」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c94096616.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「武神」怪兽作为效果对象
	Duel.SelectTarget(tp,c94096616.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的怪兽在这个回合可以直接攻击对方玩家
function c94096616.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，选择的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
