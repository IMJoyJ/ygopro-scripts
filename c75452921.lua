--トロイメア・ケルベロス
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合，丢弃1张手卡，以对方的主要怪兽区域1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
-- ②：只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不会被效果破坏。
function c75452921.initial_effect(c)
	-- 设置连接召唤手续，需要2只怪兽作为素材，且素材需满足lcheck过滤条件（卡名不同）
	aux.AddLinkProcedure(c,nil,2,2,c75452921.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，丢弃1张手卡，以对方的主要怪兽区域1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75452921,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,75452921)
	e1:SetCondition(c75452921.descon)
	e1:SetCost(c75452921.descost)
	e1:SetTarget(c75452921.destg)
	e1:SetOperation(c75452921.desop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的互相连接状态的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c75452921.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 检查连接素材的卡名是否各不相同
function c75452921.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 效果1的发动条件：此卡是连接召唤成功的场合
function c75452921.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果1的代价处理函数：丢弃1张手卡
function c75452921.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并以代价和丢弃为原因将1张手卡送去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤主要怪兽区域中特殊召唤的怪兽
function c75452921.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetSequence()<5
end
-- 效果1的目标选择与效果分类设置函数
function c75452921.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c75452921.desfilter(chkc) end
	-- 检查对方主要怪兽区域是否存在可以作为对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c75452921.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方主要怪兽区域1只特殊召唤的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c75452921.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
end
-- 效果1的效果处理函数
function c75452921.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并将其因效果破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查发动时是否处于互相连接状态且玩家当前是否可以抽卡
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否选择执行抽卡效果
		and Duel.SelectYesNo(tp,aux.Stringid(75452921,1)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续的抽卡与破坏不视为同时处理
		Duel.BreakEffect()
		-- 玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果2的适用对象过滤：自己场上处于互相连接状态的怪兽
function c75452921.indtg(e,c)
	return c:GetMutualLinkedGroupCount()>0
end
