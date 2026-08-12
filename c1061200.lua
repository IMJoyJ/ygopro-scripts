--F.A.シティGP
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段以及战斗阶段内上升2星。
-- ②：自己场上的「方程式运动员」怪兽不会成为对方的效果的对象。
-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员市街大奖赛」以外的1张「方程式运动员」卡加入手卡。
function c1061200.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段以及战斗阶段内上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为场上所有「方程式运动员」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	e2:SetValue(2)
	e2:SetCondition(c1061200.lvcon)
	c:RegisterEffect(e2)
	-- ②：自己场上的「方程式运动员」怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上所有「方程式运动员」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员市街大奖赛」以外的1张「方程式运动员」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,1061200)
	e4:SetCondition(c1061200.thcon)
	e4:SetTarget(c1061200.thtg)
	e4:SetOperation(c1061200.thop)
	c:RegisterEffect(e4)
end
-- 判断当前阶段是否为主要阶段1、主要阶段2或战斗阶段
function c1061200.lvcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 判断被破坏的原因是否为效果破坏且破坏前位置在场上正面表示
function c1061200.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索过滤函数，用于筛选「方程式运动员」卡且排除自身
function c1061200.thfilter(c)
	return c:IsSetCard(0x107) and not c:IsCode(1061200) and c:IsAbleToHand()
end
-- 设置连锁操作信息，表示将从卡组检索一张「方程式运动员」卡加入手牌
function c1061200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中存在符合条件的「方程式运动员」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1061200.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索一张「方程式运动员」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c1061200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择一张符合条件的「方程式运动员」卡
	local g=Duel.SelectMatchingCard(tp,c1061200.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
