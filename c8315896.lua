--光幻獣 カンデラード
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌丢卡特召自身并可选检索硬币卡效果、②依据手牌数提升攻守持续效果、③无效包含抽卡/检索的效果发动
function s.initial_effect(c)
	-- ①：此卡在手牌存在的场合，从手牌把此卡以外的2张卡丢弃才能发动。此卡特殊召唤。那之后，可以从卡组把1张有掷硬币效果的卡加入手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：此卡的攻击力·守备力上升自己手牌数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.adval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：包含从卡组把卡加入手牌效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- ①效果发动Cost：丢弃除自身外的2张手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- Cost检查：手牌中是否存在除自身外至少2张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,c) end
	-- 从手牌丢弃2张卡作为Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD,c)
end
-- ①效果发动准备：检查主要怪兽区域空位与自身特召条件，并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域必须有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 卡组检索过滤条件：具有掷硬币效果（EFFECT_FLAG_COIN）且能加入手牌的卡
function s.thfilter(c)
	-- 筛选带有掷硬币属性且可加入手牌的卡
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- ①效果处理：特殊召唤自身，成功时可选择从卡组检索1张掷硬币效果卡加入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁并成功表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查卡组是否存在符合条件的硬币效果卡并询问玩家是否检索
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张具有掷硬币效果的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 断开效果连接，分隔特召与检索处理
			Duel.BreakEffect()
			-- 将选择的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 攻守上升数值计算：返回自己手牌数量×1000
function s.adval(e,c)
	-- 获取控制者手牌数量并乘以1000
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end
-- ③效果发动条件：对方发动的效果包含抽卡或检索范畴，且该连锁可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	-- 判断触发连锁的效果是否包含抽卡或检索范畴且可被无效
	return (ex4 or ex5) and Duel.IsChainDisablable(ev)
end
-- ③效果发动准备：设置无效连锁效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效触发该连锁的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果处理：使发动的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果
	Duel.NegateEffect(ev)
end
