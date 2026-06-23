--瞳の魔女モルガナ
-- 效果：
-- 这个卡名在规则上也当作「魔瞳」卡使用。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「魔瞳」魔法卡加入手卡。
-- ②：对方怪兽的攻击宣言时，从自己墓地把1张「魔瞳」魔法卡除外才能发动。那次攻击无效。
-- ③：自己的墓地·除外状态的「魔瞳」魔法卡是3种类以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
local s,id,o=GetID()
-- 创建并注册该卡的4个效果，分别对应①②③效果的触发条件和处理方式
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「魔瞳」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时，从自己墓地把1张「魔瞳」魔法卡除外才能发动。那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击无效"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ③：自己的墓地·除外状态的「魔瞳」魔法卡是3种类以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力变成0"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的「魔瞳」魔法卡的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置①效果的发动条件和处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了①效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置①效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数，选择并检索满足条件的魔法卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件函数，判断是否为对方攻击宣言
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ②效果的除外卡过滤函数
function s.cfilter(c)
	return c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动处理函数，选择并除外一张「魔瞳」魔法卡
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的处理函数，无效此次攻击
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
-- ③效果的卡种类统计过滤函数
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL)
end
-- ③效果的发动条件函数，统计墓地和除外状态的「魔瞳」魔法卡种类数
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计墓地和除外状态的「魔瞳」魔法卡种类数是否不少于3种
	return Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=3
end
-- ③效果的攻击力变更过滤函数
function s.atkfilter(c,op)
	return c:IsFaceup() and (op or c:GetAttack()>0)
end
-- ③效果的发动条件和处理信息设置
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足③效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,false) end
	-- 向对方玩家提示发动了③效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理函数，将对方场上所有怪兽的攻击力设为0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,true)
	-- 遍历所有满足条件的怪兽
	for tc in aux.Next(g) do
		-- 为每个怪兽设置攻击力为0的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
