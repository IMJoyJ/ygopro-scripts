--剣の御巫ハレ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0，有装备的场合，这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
-- ②：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」装备魔法卡加入手卡。
function c18377261.initial_effect(c)
	-- ①：这张卡没有装备卡装备的场合，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c18377261.ndcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：有装备的场合，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(c18377261.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡有装备卡被装备的场合才能发动。从卡组把1张「御巫」装备魔法卡加入手卡。
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
-- e1的条件判定：当此卡没有装备卡装备（装备数量为0）时，①的“战斗伤害变成0”效果适用。
function c18377261.ndcon(e)
	return e:GetHandler():GetEquipCount()==0
end
-- e2/e3的条件判定：当此卡有装备卡装备（装备数量大于0）时，①的“不会被战斗破坏”和“战斗伤害由对方代受”效果适用。
function c18377261.indcon(e)
	return e:GetHandler():GetEquipCount()>0
end
-- 检索过滤器：要求卡为「御巫」字段（0x18d）、装备魔法卡，且能够加入手卡。
function c18377261.thfilter(c)
	return c:IsSetCard(0x18d) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- ②效果的发动判定与操作信息设置：先检查卡组是否存在符合检索条件的卡，再设置从卡组加入手卡的处理信息。
function c18377261.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：在确认发动时，检查卡组是否存在至少1张满足thfilter过滤条件的「御巫」装备魔法卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18377261.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告本次效果处理会从卡组将1张卡加入手卡，用于联动“加入手卡”相关时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张符合条件的「御巫」装备魔法卡加入手卡，并让对手确认加入的卡。
function c18377261.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选卡提示信息，提示当前玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的卡（数量为1），用于后续加入手卡。
	local g=Duel.SelectMatchingCard(tp,c18377261.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入卡持有者的手卡，加入原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将本次加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
