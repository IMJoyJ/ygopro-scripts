--幻妖フルドラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，丢弃1张手卡才能发动。丢弃的卡种类的以下效果适用。
-- ●怪兽：从自己墓地选1张陷阱卡加入手卡。
-- ●魔法：从自己墓地选1只怪兽加入手卡。
-- ●陷阱：从自己墓地选1张魔法卡加入手卡。
function c81263643.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，丢弃1张手卡才能发动。丢弃的卡种类的以下效果适用。●怪兽：从自己墓地选1张陷阱卡加入手卡。●魔法：从自己墓地选1只怪兽加入手卡。●陷阱：从自己墓地选1张魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,81263643)
	e1:SetCost(c81263643.cost)
	e1:SetTarget(c81263643.target)
	e1:SetOperation(c81263643.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可以丢弃，且自己墓地存在因该卡丢弃而能加入手牌的对应卡种卡片的卡
function c81263643.cfilter(c,tp)
	if not c:IsDiscardable() then return false end
	local ty=c:GetType() & (TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	local log=math.log(ty)/math.log(2)
	-- 检查自己墓地是否存在至少1张因丢弃该卡而对应需要加入手牌的卡种的卡
	return Duel.IsExistingMatchingCard(c81263643.filter,tp,LOCATION_GRAVE,0,1,nil,2 ^ ((log+2) % 3))
end
-- 过滤墓地中属于指定卡种且可以加入手牌的卡
function c81263643.filter(c,ty)
	return c:IsType(ty) and c:IsAbleToHand()
end
-- 效果发动的代价（Cost）处理函数：检查并丢弃1张手牌，并根据丢弃的卡种类设置对应的标记值
function c81263643.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价丢弃且能让后续效果合法适用的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81263643.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 给玩家发送提示信息，提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c81263643.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local ty=g:GetFirst():GetType() & (TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
	local log=math.log(ty)/math.log(2)
	e:SetLabel(2 ^ ((log+2) % 3))
	-- 将选择的卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的目标（Target）处理函数：设置效果分类为加入手牌，并声明操作信息
function c81263643.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果在处理时会将自己墓地的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理（Operation）函数：从自己墓地选择1张对应卡种的卡加入手牌
function c81263643.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足对应卡种（受王家之谷影响）且能加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c81263643.filter),tp,LOCATION_GRAVE,0,1,1,nil,e:GetLabel())
	if #g>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
