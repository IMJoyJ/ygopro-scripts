--サイバー・ダーク・クロー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「电子暗黑」魔法·陷阱卡加入手卡。
-- ②：有这张卡装备的怪兽进行战斗的伤害计算时才能发动。从自己的额外卡组把1只怪兽送去墓地。
-- ③：给怪兽装备的这张卡被送去墓地的场合，以自己墓地1只「电子暗黑」怪兽为对象才能发动。那只怪兽加入手卡。
function c82562802.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「电子暗黑」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82562802,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82562802)
	e1:SetCost(c82562802.cost)
	e1:SetTarget(c82562802.target)
	e1:SetOperation(c82562802.operation)
	c:RegisterEffect(e1)
	-- ②：有这张卡装备的怪兽进行战斗的伤害计算时才能发动。从自己的额外卡组把1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82562802,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,82562803)
	e2:SetCondition(c82562802.gycon)
	e2:SetTarget(c82562802.gytg)
	e2:SetOperation(c82562802.gyop)
	c:RegisterEffect(e2)
	-- ③：给怪兽装备的这张卡被送去墓地的场合，以自己墓地1只「电子暗黑」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82562802,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c82562802.con)
	e3:SetTarget(c82562802.tg)
	e3:SetOperation(c82562802.op)
	c:RegisterEffect(e3)
end
-- ①效果的代价函数：将自身从手卡丢弃
function c82562802.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手卡丢弃并送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检索卡组中可以加入手牌的「电子暗黑」魔法·陷阱卡
function c82562802.filter2(c)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组中是否存在可检索的卡，并设置回收的操作信息
function c82562802.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查卡组中是否存在至少1张满足条件的「电子暗黑」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82562802.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：从卡组选择1张「电子暗黑」魔法·陷阱卡加入手牌，并给对方确认
function c82562802.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「电子暗黑」魔法·陷阱卡
	local tg=Duel.SelectMatchingCard(tp,c82562802.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤函数：检索额外卡组中可以送去墓地的怪兽
function c82562802.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果的发动条件函数：装备了这张卡的怪兽进行战斗，且处于伤害计算时
function c82562802.gycon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否存在，且该怪兽是本次战斗的攻击怪兽或被攻击怪兽
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget())
end
-- ②效果的发动准备：检查额外卡组中是否存在可送去墓地的怪兽，并设置送去墓地的操作信息
function c82562802.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查额外卡组中是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82562802.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将额外卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理函数：从额外卡组选择1只怪兽送去墓地
function c82562802.gyop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组中选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,c82562802.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的额外卡组怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数：检索墓地中可以加入手牌的「电子暗黑」怪兽
function c82562802.filter1(c)
	return c:IsSetCard(0x4093) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的发动条件函数：这张卡此前作为装备卡在魔陷区装备，且不是因为失去装备对象而送去墓地
function c82562802.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- ③效果的发动准备：选择自己墓地1只「电子暗黑」怪兽作为对象，并设置回收的操作信息
function c82562802.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82562802.filter1(chkc) end
	-- 在发动阶段（chk==0）检查自己墓地中是否存在至少1只满足条件的「电子暗黑」怪兽
	if chk==0 then return Duel.IsExistingTarget(c82562802.filter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要加入手牌的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择墓地中1只「电子暗黑」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82562802.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息，表示该效果会将指定的对象卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的处理函数：将作为对象的墓地怪兽加入手牌，并给对方确认
function c82562802.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的目标对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标对象卡因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
	end
end
