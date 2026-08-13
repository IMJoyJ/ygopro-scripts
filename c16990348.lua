--猛進する剣闘獣
-- 效果：
-- ①：以最多有自己场上的「剑斗兽」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。
function c16990348.initial_effect(c)
	-- ①：以最多有自己场上的「剑斗兽」怪兽种类数量的场上的表侧表示的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c16990348.target)
	e1:SetOperation(c16990348.activate)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示且属于「剑斗兽」系列的怪兽，用于统计其种类数。
function c16990348.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1019)
end
-- 目标设定函数：进行取对象合法性检查与选择。若检查发动条件时，需确认自己场上有表侧表示剑斗兽怪兽且场上存在可被选择为对象的表侧表示卡；若为选择时，则让玩家选择对象。
function c16990348.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动条件检查：自己场上是否存在至少1只表侧表示的「剑斗兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16990348.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件检查：场上是否存在至少1张除本卡以外、可作为效果对象的表侧表示卡。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 取得自己场上所有表侧表示「剑斗兽」怪兽的集合，用于计算种类数量。
	local g=Duel.GetMatchingGroup(c16990348.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 给玩家显示“请选择要破坏的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上表侧表示的卡中选择1～ct张（ct为自己场上剑斗兽种类数）作为对象，并排除本卡。
	local sg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 向系统登记本次连锁将破坏的卡及其数量，以便其他卡（如星尘龙）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：连锁处理时取出本次效果的对象卡，将其中仍与效果相关的卡全部破坏。
function c16990348.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡，并筛掉已离场或与该效果失去联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选出的对象卡以“效果”的原因全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
