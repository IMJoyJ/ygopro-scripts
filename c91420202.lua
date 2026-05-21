--アドヴェンデット・セイヴァー
-- 效果：
-- 不死族怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「归魂复仇死者·屠魔侠」使用。
-- ②：以自己墓地1张「复仇死者」卡为对象才能发动。那张卡加入手卡。
-- ③：这张卡和对方怪兽进行战斗的伤害计算时，从卡组把1只不死族怪兽送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级×200。
function c91420202.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只不死族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,2)
	-- 注册卡名变更效果，使这张卡在怪兽区域存在时卡名当作「归魂复仇死者·屠魔侠」使用。
	aux.EnableChangeCode(c,4388680)
	-- ②：以自己墓地1张「复仇死者」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91420202,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,91420202)
	e2:SetTarget(c91420202.thtg)
	e2:SetOperation(c91420202.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡和对方怪兽进行战斗的伤害计算时，从卡组把1只不死族怪兽送去墓地才能发动。那只对方怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级×200。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91420202,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,91420203)
	e3:SetCondition(c91420202.atkcon)
	e3:SetCost(c91420202.atkcost)
	e3:SetOperation(c91420202.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选自己墓地中可以加入手牌的「复仇死者」卡片。
function c91420202.thfilter(c)
	return c:IsSetCard(0x106) and c:IsAbleToHand()
end
-- 效果②的发动准备（Target）函数，用于检测发动条件并选择墓地的「复仇死者」卡作为效果对象。
function c91420202.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c91420202.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手牌的「复仇死者」卡。
	if chk==0 then return Duel.IsExistingTarget(c91420202.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在客户端提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地中的1张「复仇死者」卡作为效果对象。
	local sg=Duel.SelectTarget(tp,c91420202.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，声明该效果包含将选中的卡片加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果②的处理（Operation）函数，将作为对象的卡片加入手牌。
function c91420202.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果③的发动条件函数，要求这张卡与对方怪兽进行战斗且双方都在场上。
function c91420202.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
-- 过滤函数，用于筛选卡组中可以作为发动代价送去墓地的不死族怪兽。
function c91420202.atkcfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
-- 效果③的代价（Cost）处理函数，从卡组将1只不死族怪兽送去墓地，并记录其等级。
function c91420202.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张可以送去墓地的不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c91420202.atkcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 在客户端提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只满足条件的不死族怪兽。
	local tc=Duel.SelectMatchingCard(tp,c91420202.atkcfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选中的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetLevel())
end
-- 效果③的处理（Operation）函数，使进行战斗的对方怪兽的攻击力下降送去墓地的怪兽的等级×200。
function c91420202.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local ct=e:GetLabel()*200
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and ct>0 then
		-- 那只对方怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e1)
	end
end
