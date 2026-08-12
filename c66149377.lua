--魔弾－ダンシング・ニードル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「魔弹」怪兽存在的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
function c66149377.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「魔弹」怪兽存在的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66149377+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c66149377.condition)
	e1:SetTarget(c66149377.target)
	e1:SetOperation(c66149377.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「魔弹」怪兽
function c66149377.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x108)
end
-- 发动条件：自己场上有「魔弹」怪兽存在
function c66149377.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「魔弹」怪兽
	return Duel.IsExistingMatchingCard(c66149377.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动的目标选择与操作信息注册
function c66149377.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 在发动时，检查双方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方墓地合计1到3张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果处理信息：将选中的卡从墓地除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：将作为对象的卡除外
function c66149377.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与效果有关联的对象卡片表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
