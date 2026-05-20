--S－Force チェイス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「治安战警队」怪兽种类数量的对方场上的表侧表示的卡为对象才能发动。那些卡回到持有者手卡。
-- ②：自己场上的「治安战警队」怪兽为让效果发动而把手卡除外的场合，可以作为代替把墓地的这张卡除外。
function c55049722.initial_effect(c)
	-- ①：以最多有自己场上的「治安战警队」怪兽种类数量的对方场上的表侧表示的卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,55049722)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c55049722.target)
	e1:SetOperation(c55049722.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「治安战警队」怪兽为让效果发动而把手卡除外的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(55049722)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,55049723)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为自己场上表侧表示的「治安战警队」怪兽
function c55049722.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x156)
end
-- 过滤函数：检查卡片是否为表侧表示且可以送回手牌
function c55049722.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果①的发动阶段处理：进行对象有效性检查、发动条件判断以及选择对象
function c55049722.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c55049722.thfilter(chkc) end
	-- 发动条件判断：检查自己场上是否存在「治安战警队」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55049722.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件判断：检查对方场上是否存在可以作为对象的表侧表示卡片
		and Duel.IsExistingTarget(c55049722.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取自己场上所有表侧表示的「治安战警队」怪兽卡片组
	local g=Duel.GetMatchingGroup(c55049722.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 发送系统提示信息：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择最多有自己场上「治安战警队」怪兽种类数量的对方场上的卡作为效果对象
	local sg=Duel.SelectTarget(tp,c55049722.thfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理的操作信息：将指定数量的对象卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果①的运行阶段处理：将仍与效果相关的对象卡片送回持有者手牌
function c55049722.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡片送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
