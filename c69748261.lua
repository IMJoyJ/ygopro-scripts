--ウィッチクラフト・ディストーション
local s,id,o=GetID()
-- 此函数用于注册卡片的两个效果，第一个为连锁发动时可以无效并破坏对方效果，第二个为墓地发动的检索手牌并舍弃手牌的效果
function s.initial_effect(c)
	-- 此效果为魔法卡发动效果，可以在连锁发动时无效对方的魔法或陷阱卡，并且破坏对方的魔法或陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ngcon)
	e1:SetTarget(s.ngtg)
	e1:SetOperation(s.ngop)
	c:RegisterEffect(e1)
	-- 此效果为二速效果，可以在任意时刻发动，从卡组检索一张魔法师族5星以上怪兽加入手牌，并且自己须舍弃1张手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 此效果的发动条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 此效果的发动费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.srtg)
	e2:SetOperation(s.srop)
	c:RegisterEffect(e2)
end
-- 此过滤函数用于判断场上是否存在满足条件的魔法师族怪兽（等级5以上且表侧表示）
function s.mfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5)
		and c:IsFaceup()
end
-- 此条件函数用于判断是否可以发动第一个效果，即对方发动魔法或陷阱卡时，并且场上有魔法师族怪兽
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		-- 检查连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
		-- 检查场上是否存在满足条件的魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置第一个效果的目标信息，包括使对方效果无效和破坏对方卡片
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		-- 设置操作信息为破坏对方的魔法或陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 此函数用于执行第一个效果的操作，即无效对方效果并破坏对方的魔法或陷阱卡
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方效果并且对方的卡片与连锁相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将对方的魔法或陷阱卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 此过滤函数用于判断卡组中是否存在满足条件的魔法师族怪兽（等级5以上且可以加入手牌）
function s.srfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 设置第二个效果的目标信息，包括检索一张魔法师族怪兽加入手牌和舍弃手牌
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将一张魔法师族怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息为舍弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 此函数用于执行第二个效果的操作，即检索魔法师族怪兽并舍弃手牌
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的魔法师族怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并且该卡在手牌中
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 确认对方看到自己选择加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 提示玩家选择要舍弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手牌中选择一张可以舍弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		if #dg>0 then
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 手动洗切自己的手牌
			Duel.ShuffleHand(tp)
			-- 将选择的卡送去墓地并标记为舍弃
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
