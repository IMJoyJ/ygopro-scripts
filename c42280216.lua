--太陽の神官
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地时才能发动。从卡组把1只「赤蚁」或者「苏帕伊」加入手卡。
function c42280216.initial_effect(c)
	-- 创建一个场地区域的特殊召唤规则效果，仅当对方场上存在怪兽时才能从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42280216.spcon)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，当此卡被破坏送去墓地时发动，从卡组检索「赤蚁」或「苏帕伊」加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42280216,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c42280216.shcon)
	e2:SetTarget(c42280216.shtg)
	e2:SetOperation(c42280216.shop)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤条件：自己场上没有怪兽且对方场上存在怪兽，同时自己场上还有可用召唤区域
function c42280216.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在怪兽
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用召唤区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断效果发动条件：此卡从场上被破坏送去墓地时
function c42280216.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：筛选卡号为「赤蚁」(78275321)或「苏帕伊」(78552773)且能加入手牌的卡
function c42280216.filter(c)
	return c:IsCode(78275321,78552773) and c:IsAbleToHand()
end
-- 设置效果目标：确认卡组中存在符合条件的卡，准备将一张加入手牌
function c42280216.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42280216.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备将一张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理：提示选择并检索符合条件的卡加入手牌，然后确认对方查看该卡
function c42280216.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,c42280216.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
