--闇霊神オブルミラージュ
-- 效果：
-- 这张卡不能通常召唤。自己墓地的暗属性怪兽是5只的场合才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。
-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
function c59281822.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己墓地的暗属性怪兽是5只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c59281822.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合发动。从卡组把1只攻击力1500以下的怪兽加入手卡。这个卡名的①的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59281822,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,59281822)
	e3:SetTarget(c59281822.thtg)
	e3:SetOperation(c59281822.thop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上离开的场合，下次的自己回合的战斗阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c59281822.leaveop)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：需要自己场上有可用的怪兽区域，且自己墓地的暗属性怪兽数量刚好为5只
function c59281822.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断自己墓地的暗属性怪兽数量是否刚好为5只
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)==5
end
-- 检索效果的发动准备，并设置操作信息为从卡组将1张卡加入手牌
function c59281822.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：攻击力1500以下且可以加入手牌的怪兽卡
function c59281822.thfilter(c)
	return c:IsAttackBelow(1500) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的执行：从卡组选择1只满足条件的怪兽加入手牌，并给对方确认
function c59281822.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c59281822.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 离场效果的执行：若表侧表示离场，则注册一个跳过下次自己回合战斗阶段的全局效果
function c59281822.leaveop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsFacedown() then return end
	local effp=e:GetHandler():GetControler()
	-- 下次的自己回合的战斗阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断当前回合玩家是否为这张卡的控制者（即是否在自己的回合离场）
	if Duel.GetTurnPlayer()==effp then
		-- 将当前回合数记录在效果的Label中，用于后续判断以避免在当前回合生效
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c59281822.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 将跳过战斗阶段的效果注册给该卡的控制者
	Duel.RegisterEffect(e1,effp)
end
-- 跳过战斗阶段效果的生效条件：当前回合数不等于记录的离场回合数（确保不在离场的当前回合跳过战斗阶段）
function c59281822.skipcon(e)
	-- 判断当前回合数是否不等于记录的离场回合数
	return Duel.GetTurnCount()~=e:GetLabel()
end
