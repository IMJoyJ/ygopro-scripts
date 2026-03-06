--ゴースト王－パンプキング－
-- 效果：
-- 只要「暗晦之城」在场上表侧表示存在，这张卡的攻击力·守备力上升100。此外，每次自己的准备阶段再上升100。这个效果持续到自己的第4个准备阶段。
function c29155212.initial_effect(c)
	-- 只要「暗晦之城」在场上表侧表示存在，这张卡的攻击力上升100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c29155212.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 此外，每次自己的准备阶段再上升100。这个效果持续到自己的第4个准备阶段。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29155212,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c29155212.atkcon)
	e3:SetOperation(c29155212.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「暗晦之城」
function c29155212.filter(c)
	return c:IsFaceup() and c:IsCode(62121)
end
-- 计算攻击力时的附加值函数，根据是否满足条件和已触发次数决定增加量
function c29155212.adval(e,c)
	-- 检查场上是否存在满足filter条件的卡
	if Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		return 100+c:GetFlagEffect(29155212)*100
	else
		return c:GetFlagEffect(29155212)*100
	end
end
-- 判断是否为自己的准备阶段且未达到4次触发次数，并且场上存在「暗晦之城」
function c29155212.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(29155212)<4
		-- 检查场上是否存在「暗晦之城」
		and Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 准备阶段触发效果的处理函数，记录一次触发次数
function c29155212.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果持有者是否仍然存在于场上且场上存在「暗晦之城」
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	e:GetHandler():RegisterFlagEffect(29155212,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
end
