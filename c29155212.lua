--ゴースト王－パンプキング－
-- 效果：
-- 只要「暗晦之城」在场上表侧表示存在，这张卡的攻击力·守备力上升100。此外，每次自己的准备阶段再上升100。这个效果持续到自己的第4个准备阶段。
function c29155212.initial_effect(c)
	-- 只要「暗晦之城」在场上表侧表示存在，这张卡的攻击力·守备力上升100。
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
-- 过滤函数：判断卡片是否为表侧表示且卡号为62121，用于检测场上是否存在表侧表示的「暗晦之城」。
function c29155212.filter(c)
	return c:IsFaceup() and c:IsCode(62121)
end
-- 计算提升数值：若场上有表侧表示「暗晦之城」，则返回100加上已累计的准备阶段次数×100；否则只返回已累计次数×100。
function c29155212.adval(e,c)
	-- 检查双方场上是否存在至少1张表侧表示的「暗晦之城」，作为是否获得基础100点提升的条件。
	if Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		return 100+c:GetFlagEffect(29155212)*100
	else
		return c:GetFlagEffect(29155212)*100
	end
end
-- 准备阶段触发效果的条件：当前回合玩家是自己、这张卡已累计的准备阶段次数少于4（即效果未超过第4次准备阶段），且场上有表侧表示「暗晦之城」。
function c29155212.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是（自己的）准备阶段，且此卡已累计的准备阶段次数小于4，确保效果仍在持续期间内。
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(29155212)<4
		-- 确认场上存在表侧表示的「暗晦之城」，否则准备阶段效果不发动。
		and Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 准备阶段效果处理：若此卡仍与效果有联系且场上有表侧表示「暗晦之城」，则为此卡注册一个计数值为1的标识，记录攻击力·守备力已追加上升的次数。
function c29155212.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前的安全校验：若此卡已离场导致与效果失去联系，或场上已不存在表侧表示的「暗晦之城」，则中止本次效果处理。
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(c29155212.filter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	e:GetHandler():RegisterFlagEffect(29155212,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,1)
end
