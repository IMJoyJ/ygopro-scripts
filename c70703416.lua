--氷結界の霜精
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有其他的「冰结界」怪兽存在，对方场上的怪兽的攻击力·守备力下降500。
-- ②：自己主要阶段才能发动。从卡组把1只3星以下的「冰结界」怪兽送去墓地。这张卡的等级直到回合结束时变成和那只怪兽相同。
function c70703416.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，对方场上的怪兽的攻击力·守备力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-500)
	e1:SetCondition(c70703416.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组把1只3星以下的「冰结界」怪兽送去墓地。这张卡的等级直到回合结束时变成和那只怪兽相同。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70703416,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,70703416)
	e3:SetTarget(c70703416.lvtg)
	e3:SetOperation(c70703416.lvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「冰结界」怪兽
function c70703416.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 效果①的适用条件：自己场上存在自身以外的「冰结界」怪兽
function c70703416.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1只自身以外的表侧表示「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c70703416.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤条件：卡组中等级3以下且可以送去墓地的「冰结界」怪兽
function c70703416.tgfilter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x2f) and c:IsAbleToGrave()
end
-- 效果②的发动准备与检测：检查卡组中是否存在可送去墓地的怪兽，并设置送墓的操作信息
function c70703416.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查卡组中是否存在至少1只满足条件的「冰结界」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c70703416.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：将卡组中1只等级3以下的「冰结界」怪兽送去墓地，并使自身等级直到回合结束时变成与该怪兽相同
function c70703416.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足条件的「冰结界」怪兽
	local g=Duel.SelectMatchingCard(tp,c70703416.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将怪兽送去墓地，且自身仍在场上表侧表示存在
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
