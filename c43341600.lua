--フライアのリンゴ
-- 效果：
-- ①：以最多有自己场上的「女武神」怪兽数量的对方墓地的卡为对象才能发动。那些卡除外。
-- ②：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。自己从卡组抽出自己场上的「女武神」怪兽的数量＋1张。
function c43341600.initial_effect(c)
	-- ①：以最多有自己场上的「女武神」怪兽数量的对方墓地的卡为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c43341600.target)
	e1:SetOperation(c43341600.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡因对方的效果从场上离开，被送去墓地的场合或者被除外的场合才能发动。自己从卡组抽出自己场上的「女武神」怪兽的数量＋1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c43341600.drcon)
	e2:SetTarget(c43341600.drtg)
	e2:SetOperation(c43341600.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有「女武神」怪兽
function c43341600.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c43341600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAbleToRemove() and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在至少1只「女武神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c43341600.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方墓地是否存在至少1张可除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 计算自己场上「女武神」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择最多与自己场上「女武神」怪兽数量相同的对方墓地的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
	-- 设置效果处理信息，将要除外的卡组和数量记录到连锁操作信息中
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理函数，将选中的卡除外
function c43341600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因将卡组除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断此卡是否因对方效果从场上离开并送去墓地或除外
function c43341600.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp~=tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 设置抽卡效果的目标和数量
function c43341600.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上「女武神」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct+1) end
	-- 设置效果处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理信息，将要抽卡的数量记录到连锁操作信息中
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
end
-- 效果处理函数，进行抽卡操作
function c43341600.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算目标玩家场上「女武神」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c43341600.cfilter,p,LOCATION_MZONE,0,nil)
	-- 让目标玩家从卡组抽卡
	Duel.Draw(p,ct+1,REASON_EFFECT)
end
