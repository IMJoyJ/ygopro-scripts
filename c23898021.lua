--悪魔嬢リリス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：召唤的这张卡的原本攻击力变成1000。
-- ②：把自己场上1只暗属性怪兽解放才能发动。从卡组把3张通常陷阱卡给对方观看，对方从那之中随机选1张。那1张卡在自己场上盖放，剩下的卡回到卡组。这个效果在对方回合也能发动。
function c23898021.initial_effect(c)
	-- ①：召唤的这张卡的原本攻击力变成1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c23898021.regop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只暗属性怪兽解放才能发动。从卡组把3张通常陷阱卡给对方观看，对方从那之中随机选1张。那1张卡在自己场上盖放，剩下的卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,23898021)
	e2:SetCost(c23898021.thcost)
	e2:SetTarget(c23898021.thtg)
	e2:SetOperation(c23898021.thop)
	c:RegisterEffect(e2)
end
-- 将自身原本攻击力设置为1000
function c23898021.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置自身原本攻击力变成1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 支付效果代价：解放1只暗属性怪兽
function c23898021.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放1只暗属性怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 选择1只可解放的暗属性怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 将选中的怪兽解放作为代价
	Duel.Release(g,REASON_COST)
end
-- 过滤函数：筛选可盖放的通常陷阱卡
function c23898021.thfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 设置效果发动时的处理信息：从卡组检索3张通常陷阱卡
function c23898021.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在至少3张通常陷阱卡
		and Duel.IsExistingMatchingCard(c23898021.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁操作信息：将卡牌移至手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择3张通常陷阱卡，由对方选择1张盖放，其余返回卡组
function c23898021.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索卡组中所有可盖放的通常陷阱卡
	local g=Duel.GetMatchingGroup(c23898021.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 向对方确认所选的3张卡
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 将选中的陷阱卡在自己场上盖放
		Duel.SSet(tp,tg,tp,false)
	end
end
