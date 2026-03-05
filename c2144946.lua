--F.A.オフロードGP
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段内上升2星。
-- ②：自己的「方程式运动员」怪兽被战斗破坏时才能发动。对方手卡随机选1张丢弃。
-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员越野大奖赛」以外的1张「方程式运动员」卡加入手卡。
function c2144946.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段内上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为场上所有「方程式运动员」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	e2:SetValue(2)
	e2:SetCondition(c2144946.lvcon)
	c:RegisterEffect(e2)
	-- ②：自己的「方程式运动员」怪兽被战斗破坏时才能发动。对方手卡随机选1张丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2144946,0))
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,2144946)
	e3:SetCondition(c2144946.descon)
	e3:SetTarget(c2144946.destg)
	e3:SetOperation(c2144946.desop)
	c:RegisterEffect(e3)
	-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员越野大奖赛」以外的1张「方程式运动员」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2144946,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,2144947)
	e4:SetCondition(c2144946.thcon2)
	e4:SetTarget(c2144946.thtg2)
	e4:SetOperation(c2144946.thop2)
	c:RegisterEffect(e4)
end
-- 判断当前是否处于主要阶段1或主要阶段2
function c2144946.lvcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 判断目标怪兽是否为我方控制且属于「方程式运动员」卡组
function c2144946.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x107)
end
-- 判断是否有我方「方程式运动员」怪兽被战斗破坏
function c2144946.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c2144946.cfilter,1,nil,tp)
end
-- 判断对方手牌数量是否大于0
function c2144946.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置连锁操作信息为对方丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 执行对方随机丢弃1张手牌的操作
function c2144946.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选择的对方手牌送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
-- 判断此卡是否因效果破坏且之前在场地区域表侧表示
function c2144946.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤出卡组中非此卡的「方程式运动员」卡
function c2144946.thfilter2(c)
	return c:IsSetCard(0x107) and not c:IsCode(2144946) and c:IsAbleToHand()
end
-- 判断卡组中是否存在满足条件的「方程式运动员」卡
function c2144946.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「方程式运动员」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2144946.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为从卡组检索1张「方程式运动员」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行从卡组检索并加入手牌的操作
function c2144946.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「方程式运动员」卡
	local g=Duel.SelectMatchingCard(tp,c2144946.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
