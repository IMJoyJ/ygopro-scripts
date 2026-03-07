--超重武者ダイ－8
-- 效果：
-- 「超重武者 大八-8」的③的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ③：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己场上的表侧守备表示的这张卡变成攻击表示，从卡组把1只「超重武者装留」怪兽加入手卡。
function c34496660.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34496660,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c34496660.postg)
	e1:SetOperation(c34496660.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：自己墓地没有魔法·陷阱卡存在的场合才能发动。自己场上的表侧守备表示的这张卡变成攻击表示，从卡组把1只「超重武者装留」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34496660,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,34496660)
	e4:SetCondition(c34496660.thcon)
	e4:SetTarget(c34496660.thtg)
	e4:SetOperation(c34496660.thop)
	c:RegisterEffect(e4)
end
-- 设置效果发动时的操作信息，用于确定效果处理中要改变表示形式的卡
function c34496660.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，包含要改变表示形式的卡
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 设置效果发动时的操作信息，用于确定效果处理中要改变表示形式的卡
function c34496660.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将目标怪兽的表示形式从表侧守备变为表侧攻击
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 判断效果发动条件：确认此卡处于表侧守备表示且自己墓地没有魔法·陷阱卡
function c34496660.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
		-- 检查自己墓地是否存在魔法或陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数，用于筛选「超重武者装留」系列且能加入手牌的怪兽
function c34496660.thfilter(c)
	return c:IsSetCard(0x109a) and c:IsAbleToHand()
end
-- 设置效果发动时的操作信息，用于确定效果处理中要加入手牌的卡
function c34496660.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中存在符合条件的「超重武者装留」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34496660.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的连锁的操作信息，包含要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的操作：将目标怪兽从表侧守备变为表侧攻击并检索卡组中的「超重武者装留」怪兽
function c34496660.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查效果发动的前置条件：目标怪兽是否有效且处于表侧守备表示
	if not c:IsRelateToEffect(e) or not c:IsPosition(POS_FACEUP_DEFENSE) or Duel.ChangePosition(c,POS_FACEUP_ATTACK)==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「超重武者装留」怪兽
	local g=Duel.SelectMatchingCard(tp,c34496660.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
