--猛進する剣闘獣
-- 效果：
-- ①：以最多有自己场上的「剑斗兽」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。
function c16990348.initial_effect(c)
	-- 效果原文内容：①：以最多有自己场上的「剑斗兽」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16990348.target)
	e1:SetOperation(c16990348.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选场上表侧表示的「剑斗兽」怪兽
function c16990348.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 效果作用：检查是否满足发动条件，即自己场上存在表侧表示的「剑斗兽」怪兽且场上存在至少一张表侧表示的卡作为对象
function c16990348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 效果作用：检查自己场上是否存在至少一张表侧表示的「剑斗兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16990348.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查场上是否存在至少一张表侧表示的卡作为对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 效果作用：获取自己场上所有表侧表示的「剑斗兽」怪兽
	local g=Duel.GetMatchingGroup(c16990348.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择最多与自己场上「剑斗兽」怪兽种类数量相同的场上表侧表示的卡作为破坏对象
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 效果作用：设置连锁操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果作用：处理连锁效果，将选中的卡破坏
function c16990348.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中选定的目标卡组并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：以效果为原因将卡组中的卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
