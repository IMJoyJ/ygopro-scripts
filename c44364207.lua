--ジェイドナイト
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，自己场上表侧表示存在的攻击力1200以下的机械族怪兽不会被陷阱卡的效果破坏。场上表侧表示存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把1只光属性·机械族的4星怪兽加入手卡。
function c44364207.initial_effect(c)
	-- 永续效果，只要这张卡在自己场上表侧攻击表示存在，自己场上表侧表示存在的攻击力1200以下的机械族怪兽不会被陷阱卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c44364207.indescon)
	e1:SetTarget(c44364207.indestg)
	e1:SetValue(c44364207.indesval)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把1只光属性·机械族的4星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44364207,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c44364207.condition)
	e2:SetTarget(c44364207.target)
	e2:SetOperation(c44364207.operation)
	c:RegisterEffect(e2)
end
-- 效果适用条件：这张卡必须处于攻击表示
function c44364207.indescon(e)
	return e:GetHandler():IsAttackPos()
end
-- 效果适用对象：自己场上表侧表示存在的攻击力1200以下的机械族怪兽
function c44364207.indestg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttackBelow(1200)
end
-- 效果值：使陷阱卡的效果无法破坏
function c44364207.indesval(e,re)
	return re:GetHandler():IsType(TYPE_TRAP)
end
-- 发动条件：这张卡因战斗破坏而送去墓地
function c44364207.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索卡牌的过滤条件：光属性、机械族、4星、可以加入手牌
function c44364207.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果处理前的确认：确认自己卡组是否存在满足条件的卡
function c44364207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果处理前的确认：确认自己卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44364207.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备从卡组检索1张满足条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择1张满足条件的卡加入手牌并确认
function c44364207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c44364207.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
