--剛鬼ガッツ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：守备表示的这张卡不会被战斗破坏。
-- ②：自己主要阶段才能发动。自己场上的全部「刚鬼」怪兽的攻击力上升200。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 毅力鬼」以外的1张「刚鬼」卡加入手卡。
function c7540107.initial_effect(c)
	-- ①：守备表示的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c7540107.indcon)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己场上的全部「刚鬼」怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7540107,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,7540107)
	e2:SetTarget(c7540107.atktg)
	e2:SetOperation(c7540107.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「刚鬼 毅力鬼」以外的1张「刚鬼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7540107,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,7540108)
	e3:SetCondition(c7540107.thcon)
	e3:SetTarget(c7540107.thtg)
	e3:SetOperation(c7540107.thop)
	c:RegisterEffect(e3)
end
-- 判断这张卡是否处于守备表示
function c7540107.indcon(e)
	return e:GetHandler():IsDefensePos()
end
-- 过滤条件：场上表侧表示的「刚鬼」怪兽
function c7540107.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
-- 攻击力上升效果的发动检测与目标选择函数
function c7540107.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：自己场上是否存在至少1只表侧表示的「刚鬼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7540107.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 攻击力上升效果的执行函数
function c7540107.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「刚鬼」怪兽
	local g=Duel.GetMatchingGroup(c7540107.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力上升200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 判断这张卡此前是否在场上，用于确认是否是从场上送去墓地
function c7540107.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中「刚鬼 毅力鬼」以外的可以加入手牌的「刚鬼」卡
function c7540107.thfilter(c)
	return c:IsSetCard(0xfc) and not c:IsCode(7540107) and c:IsAbleToHand()
end
-- 检索效果的发动检测与效果分类设置函数
function c7540107.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：卡组中是否存在满足条件的「刚鬼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c7540107.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function c7540107.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「刚鬼」卡
	local g=Duel.SelectMatchingCard(tp,c7540107.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
