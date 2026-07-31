--KYOUTOUウォーターフロント
-- 效果：
-- ①：每次场上的卡被送去墓地，每有1张给这张卡放置1个坏兽指示物（最多5个）。
-- ②：1回合1次，这张卡的坏兽指示物是3个以上的场合才能发动。自己从卡组把1只「坏兽」怪兽加入手卡。
-- ③：这张卡被效果破坏的场合，可以作为代替把这张卡1个坏兽指示物取除。
function c56111151.initial_effect(c)
	c:EnableCounterPermit(0x37)
	c:SetCounterLimit(0x37,5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次场上的卡被送去墓地，每有1张给这张卡放置1个坏兽指示物（最多5个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c56111151.counter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡的坏兽指示物是3个以上的场合才能发动。自己从卡组把1只「坏兽」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c56111151.thcon)
	e3:SetTarget(c56111151.thtg)
	e3:SetOperation(c56111151.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果破坏的场合，可以作为代替把这张卡1个坏兽指示物去除。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(c56111151.desreptg)
	e4:SetOperation(c56111151.desrepop)
	c:RegisterEffect(e4)
end
c56111151.mentioned_counter={
	[0x37]=true,
}
-- 卡片位置变更过滤：确认卡片此前在场上
function c56111151.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 放置指示物处理：按从场上送去墓地的卡片张数放置坏兽指示物
function c56111151.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c56111151.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x37,ct,true)
	end
end
-- 卡组检索过滤条件：「坏兽」怪兽且可加入手牌
function c56111151.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果发动条件：此卡的坏兽指示物数量在3个以上
function c56111151.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
-- 检索效果发动准备：设置从卡组检索「坏兽」怪兽的操作信息
function c56111151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在「坏兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56111151.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组将1只「坏兽」怪兽加入手牌
function c56111151.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「坏兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c56111151.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏代替效果准备：检查此卡是否被效果破坏及是否有坏兽指示物
function c56111151.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		and e:GetHandler():IsCanRemoveCounter(tp,0x37,1,REASON_EFFECT) end
	-- 询问玩家是否选择去除坏兽指示物代替破坏
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 破坏代替效果处理：去除此卡的1个坏兽指示物
function c56111151.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x37,1,REASON_EFFECT)
end
