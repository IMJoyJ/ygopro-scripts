--ジェイドナイト
-- 效果：
-- 只要这张卡在自己场上表侧攻击表示存在，自己场上表侧表示存在的攻击力1200以下的机械族怪兽不会被陷阱卡的效果破坏。场上表侧表示存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把1只光属性·机械族的4星怪兽加入手卡。
function c44364207.initial_effect(c)
	-- 只要这张卡在自己场上表侧攻击表示存在，自己场上表侧表示存在的攻击力1200以下的机械族怪兽不会被陷阱卡的效果破坏。
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
-- 判断翡翠骑士是否处于攻击表示，以决定其保护效果是否适用。
function c44364207.indescon(e)
	return e:GetHandler():IsAttackPos()
end
-- 筛选受保护的对象：必须是机械族且攻击力1200以下的表侧表示怪兽。
function c44364207.indestg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttackBelow(1200)
end
-- 判定将要发生的破坏效果是否来自陷阱卡，若是陷阱卡的效果则保护生效。
function c44364207.indesval(e,re)
	return re:GetHandler():IsType(TYPE_TRAP)
end
-- 检测这张卡是否因战斗破坏被送去墓地，且破坏前为表侧表示，满足则诱发检索效果。
function c44364207.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 定义检索目标的条件：光属性、机械族、4星且能够加入手卡的怪兽。
function c44364207.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 发动时的目标检查与操作信息设置：确认卡组存在可检索的怪兽，并将本效果登记为卡组检索加入手牌。
function c44364207.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性验证：卡组中至少存在1只满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44364207.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息，预告将从卡组把1张卡加入手牌，供其他卡片进行时点/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选取1只符合条件的怪兽加入手牌并向对方展示。
function c44364207.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，告知玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中筛选并选择1张符合条件的机械族光属性4星怪兽。
	local g=Duel.SelectMatchingCard(tp,c44364207.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次检索加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
