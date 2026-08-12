--空牙団の奥義
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以最多有自己场上的「空牙团」怪兽种类数量的场上的表侧表示卡为对象才能发动。那些卡破坏。自己场上有8星以上以及连接3以上的「空牙团」怪兽各存在的场合，也能作为代替把作为对象的卡全部除外。
-- ②：这张卡在墓地存在的状态，自己场上有8星以上或连接3以上的「空牙团」怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①效果（破坏/除外场上表侧卡）和②效果（墓地回收）
function s.initial_effect(c)
	-- ①：以最多有自己场上的「空牙团」怪兽种类数量的场上的表侧表示卡为对象才能发动。那些卡破坏。自己场上有8星以上以及连接3以上的「空牙团」怪兽各存在的场合，也能作为代替把作为对象的卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上有8星以上或连接3以上的「空牙团」怪兽特殊召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「空牙团」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- ①效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 判断自己场上是否存在至少1只表侧表示的「空牙团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断场上是否存在至少1张除这张卡以外的表侧表示卡片作为对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 获取自己场上所有表侧表示的「空牙团」怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于自己场上「空牙团」怪兽种类数量的场上表侧表示卡片作为对象
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 如果自己场上不同时存在8星以上的「空牙团」怪兽
	if not (Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
			-- 以及连接3以上的「空牙团」怪兽
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
			and sg:IsExists(Card.IsAbleToRemove,1,nil)) then
		-- 设置效果处理信息为破坏所选的对象卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	end
end
-- 过滤条件：自己场上表侧表示的8星以上的「空牙团」怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsLevelAbove(8)
end
-- 过滤条件：自己场上表侧表示的连接3以上的「空牙团」怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and c:IsLinkAbove(3)
end
-- ①效果的处理：根据条件选择将对象卡破坏或除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍存在于场上且与当前连锁相关的对象卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToChain,nil)
	-- 如果所有对象卡都可以被除外
	if not g:IsExists(aux.NOT(Card.IsAbleToRemove),1,nil)
		-- 且自己场上存在8星以上的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己场上存在连接3以上的「空牙团」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
		-- 且玩家选择作为代替将对象卡全部除外
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否作为代替除外？"
		-- 将对象卡全部除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	else
		-- 将对象卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上特殊召唤成功的、表侧表示的8星以上或连接3以上的「空牙团」怪兽
function s.cthfilter(c,tp)
	return c:IsSetCard(0x114) and c:IsFaceup() and c:IsControler(tp)
		and (c:IsLevelAbove(8) or c:IsLinkAbove(3))
end
-- ②效果的发动条件：自己场上有8星以上或连接3以上的「空牙团」怪兽特殊召唤的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cthfilter,1,nil,tp)
end
-- ②效果的发动准备：检查自身是否能加入手卡，并设置效果处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息为将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理：将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍存在于墓地且不受「王家长眠之谷」的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
