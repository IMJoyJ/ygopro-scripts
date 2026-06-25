--ウィッチクラフト・ディストーション
local s,id,o=GetID()
-- 注册卡片效果的入口函数，定义并注册此卡的效果。
function s.initial_effect(c)
	-- ①：自己场上有5星以上的「魔女术」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
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
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的魔法师族怪兽加入手卡。之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置墓地效果（效果②）在被送去墓地的回合不能发动的条件
	e2:SetCondition(aux.exccon)
	-- 设置墓地效果（效果②）的代价为将墓地的此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.srtg)
	e2:SetOperation(s.srop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，筛选我方场上表侧表示且等级在5星以上的「魔女术」怪兽
function s.mfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5)
		and c:IsFaceup()
end
-- 定义无效发动效果（效果①）的发动条件判断函数
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		-- 判断当前发动的卡或效果是否可以被无效化
		and Duel.IsChainNegatable(ev)
		-- 判断我方场上是否存在5星以上的表侧表示「魔女术」怪兽
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义无效发动效果（效果①）的发动准备与检查函数（Target）
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将该发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		-- 设置将该发动的卡破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义无效发动效果（效果①）的实际执行逻辑函数（Operation）
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该卡的发动，并判断该卡是否与该连锁关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将已被无效发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义过滤函数，筛选卡组中5星以上的可以加入手牌的魔法师族怪兽
function s.srfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 定义墓地检索手牌效果（效果②）的发动准备与检查函数（Target）
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的5星以上魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置我方需要丢弃1张手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 定义墓地检索手牌效果（效果②）的实际执行逻辑函数（Operation）
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只符合条件的5星以上魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选定的怪兽加入手牌，并确认该卡已成功到达手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 向对方展示玩家加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 给玩家提示：选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让玩家从手牌中选择1张可以被效果丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		if #dg>0 then
			-- 中断效果处理，使后续丢弃手牌与之前的加入手牌操作视为不同时处理
			Duel.BreakEffect()
			-- 洗涤我方的手牌以隐藏所加卡片在手牌中的位置
			Duel.ShuffleHand(tp)
			-- 执行丢弃选定手牌的操作，将其送入墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
