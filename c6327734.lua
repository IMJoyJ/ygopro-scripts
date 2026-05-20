--珠の御巫フゥリ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0，有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ②：只要自己场上有装备卡存在，对方不能把自己场上的「御巫」卡作为效果的对象。
-- ③：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」陷阱卡加入手卡。
function c6327734.initial_effect(c)
	-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c6327734.ndcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(c6327734.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：只要自己场上有装备卡存在，对方不能把自己场上的「御巫」卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetCondition(c6327734.tgcon)
	-- 设置效果的影响对象为自己场上的「御巫」卡
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x18d))
	-- 设置不能成为对方卡的效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ③：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」陷阱卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(6327734,0))  --"卡组检索"
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_EQUIP)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,6327734)
	e5:SetTarget(c6327734.thtg)
	e5:SetOperation(c6327734.thop)
	c:RegisterEffect(e5)
end
-- 判断自身是否没有装备卡装备的条件函数
function c6327734.ndcon(e)
	return e:GetHandler():GetEquipCount()==0
end
-- 判断自身是否有装备卡装备的条件函数
function c6327734.indcon(e)
	return e:GetHandler():GetEquipCount()>0
end
-- 过滤场上的装备卡（包括装备中的卡和表侧表示的装备魔法卡）
function c6327734.indcfilter(c)
	return c:GetEquipTarget() or (c:IsFaceup() and c:IsType(TYPE_EQUIP))
end
-- 判断自己场上是否存在装备卡的条件函数
function c6327734.tgcon(e)
	-- 检查自己场上是否存在至少1张装备卡
	return Duel.IsExistingMatchingCard(c6327734.indcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 过滤卡组中可以加入手牌的「御巫」陷阱卡
function c6327734.thfilter(c)
	return c:IsSetCard(0x18d) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动准备与效果分类注册函数
function c6327734.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张可检索的「御巫」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6327734.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function c6327734.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「御巫」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c6327734.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
