--ナチュル・ナーブ
-- 效果：
-- ①：对方把魔法·陷阱卡发动时，把这张卡和自己场上1只「自然」怪兽解放才能发动。那个发动无效并破坏。
function c16940215.initial_effect(c)
	-- ①：对方把魔法·陷阱卡发动时，把这张卡和自己场上1只「自然」怪兽解放才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16940215,0))  --"魔法陷阱发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c16940215.discon)
	e1:SetCost(c16940215.discost)
	e1:SetTarget(c16940215.distg)
	e1:SetOperation(c16940215.disop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方发动魔法或陷阱卡，且该连锁可被无效，且自身未在战斗破坏状态
function c16940215.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动魔法或陷阱卡，且该连锁可被无效
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 过滤「自然」怪兽（种族为0x2a）且未在战斗破坏状态的怪兽
function c16940215.cfilter(c)
	return c:IsSetCard(0x2a) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 处理发动此效果所需的费用，可选择丢弃2张手牌或解放自身与1只「自然」怪兽
function c16940215.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【自然山茶】(29942771)的效果是否生效中。若在生效中，，自己为让「自然」怪兽的效果发动而把怪兽解放的场合，可以作为代替从自己卡组上面把2张卡送去墓地。
	local fe=Duel.IsPlayerAffectedByEffect(tp,29942771)
	-- 判断玩家是否能作为费用丢弃2张卡到墓地
	local b1=fe and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
	-- 判断玩家是否能解放自身与1只「自然」怪兽
	local b2=c:IsReleasable() and Duel.CheckReleaseGroup(tp,c16940215.cfilter,1,c)
	if chk==0 then return b1 or b2 end
	-- 若选择丢弃2张卡的费用，则执行丢弃操作
	if b1 and (not b2 or Duel.SelectYesNo(tp,fe:GetDescription())) then
		-- 提示使用自然山茶的效果
		Duel.Hint(HINT_CARD,0,29942771)
		fe:UseCountLimit(tp)
		-- 执行丢弃2张卡到墓地的操作
		Duel.DiscardDeck(tp,2,REASON_COST)
	else
		-- 选择1只「自然」怪兽进行解放
		local g=Duel.SelectReleaseGroup(tp,c16940215.cfilter,1,1,c)
		g:AddCard(c)
		-- 执行解放操作
		Duel.Release(g,REASON_COST)
	end
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏
function c16940215.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行使发动无效并破坏的操作
function c16940215.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使发动无效且发动卡仍有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
