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
	-- ③：这张卡被效果破坏的场合，可以作为代替把这张卡1个坏兽指示物取除。
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
-- 过滤函数：筛选本次事件中原来在场上、之后被送去墓地的卡。
function c56111151.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 永续处理：统计本次送去墓地的卡中原本在场上的卡的数量，每有1张就给这张卡放置1个坏兽指示物。
function c56111151.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c56111151.cfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x37,ct,true)
	end
end
-- 过滤函数：检索卡组中可以加入手卡的「坏兽」怪兽。
function c56111151.thfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动条件：这张卡的坏兽指示物是3个以上的场合才能发动。
function c56111151.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)>=3
end
-- 目标检查：确认卡组中存在可以加入手卡的「坏兽」怪兽，并设置操作信息声明将从卡组把1张卡加入手卡。
function c56111151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：确认自己卡组中存在至少1只可以加入手卡的「坏兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c56111151.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明此效果将把自己卡组的1张卡加入手卡，供其他卡（如王家长眠之谷）的连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：让玩家从自己卡组选择1只「坏兽」怪兽加入手卡，加入后展示给对方确认。
function c56111151.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选卡提示文字「请选择要加入手牌的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的「坏兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c56111151.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的怪兽以效果原因加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代替破坏的适用检查：本次破坏不是因代替破坏引起，且这张卡可以取除1个坏兽指示物。
function c56111151.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE)
		and e:GetHandler():IsCanRemoveCounter(tp,0x37,1,REASON_EFFECT) end
	-- 询问玩家是否适用代替破坏（把这张卡1个坏兽指示物取除来代替破坏）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的处理：把这张卡1个坏兽指示物取除，以此代替这次破坏。
function c56111151.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x37,1,REASON_EFFECT)
end
