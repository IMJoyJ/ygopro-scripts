--海皇の竜騎隊
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的3星以下的海龙族怪兽可以直接攻击。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。从卡组把「海皇的龙骑队」以外的1只海龙族怪兽加入手卡。
function c74311226.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的3星以下的海龙族怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c74311226.datg)
	c:RegisterEffect(e1)
	-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。从卡组把「海皇的龙骑队」以外的1只海龙族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74311226,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c74311226.thcon)
	e2:SetTarget(c74311226.thtg)
	e2:SetOperation(c74311226.thop)
	c:RegisterEffect(e2)
end
-- 过滤出等级3以下的海龙族怪兽作为可以直接攻击的对象
function c74311226.datg(e,c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_SEASERPENT)
end
-- 检查这张卡是否是作为水属性怪兽效果发动的代价（COST）而被送去墓地
function c74311226.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤出卡组中「海皇的龙骑队」以外的、可以加入手卡的海龙族怪兽
function c74311226.thfilter(c)
	return not c:IsCode(74311226) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 效果发动的目标检测与操作信息设置（必发效果，直接返回true并设置检索卡组的操作信息）
function c74311226.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的海龙族怪兽加入手卡，并给对方确认
function c74311226.thop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件（非同名海龙族）的卡
	local g=Duel.SelectMatchingCard(tp,c74311226.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
