--剣の御巫ハレ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0，有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」装备魔法卡加入手卡。
function c18377261.initial_effect(c)
	-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18377261.ndcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(c18377261.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」装备魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_EQUIP)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,18377261)
	e4:SetTarget(c18377261.thtg)
	e4:SetOperation(c18377261.thop)
	c:RegisterEffect(e4)
end
-- 当此卡没有装备卡装备时触发效果
function c18377261.ndcon(e)
	return e:GetHandler():GetEquipCount()==0
end
-- 当此卡有装备卡装备时触发效果
function c18377261.indcon(e)
	return e:GetHandler():GetEquipCount()>0
end
-- 检索满足条件的「御巫」装备魔法卡
function c18377261.thfilter(c)
	return c:IsSetCard(0x18d) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「御巫」装备魔法卡
function c18377261.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「御巫」装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18377261.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「御巫」装备魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作，包括选择并加入手牌
function c18377261.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「御巫」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c18377261.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
