--ネフティスの希望
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张「奈芙提斯」卡和对方场上1张卡为对象才能发动。那些卡破坏。
function c50847759.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50847759+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c50847759.target)
	e1:SetOperation(c50847759.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：筛选场上表侧表示的「奈芙提斯」卡
function c50847759.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11f)
end
-- 效果作用：检查是否满足发动条件，即自己场上存在1张「奈芙提斯」卡和对方场上存在1张卡
function c50847759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果作用：检查自己场上是否存在1张「奈芙提斯」卡
	if chk==0 then return Duel.IsExistingTarget(c50847759.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 效果作用：检查对方场上是否存在至少1张卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择自己场上的1张「奈芙提斯」卡作为对象
	local g1=Duel.SelectTarget(tp,c50847759.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 效果作用：向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择对方场上的1张卡作为对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 效果作用：设置连锁操作信息，指定将要破坏的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果原文内容：①：以自己场上1张「奈芙提斯」卡和对方场上1张卡为对象才能发动。那些卡破坏。
function c50847759.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中设定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 效果作用：将目标卡片组中的卡因效果破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
