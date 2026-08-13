--ネフティスの希望
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张「奈芙提斯」卡和对方场上1张卡为对象才能发动。那些卡破坏。
function c50847759.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1张「奈芙提斯」卡和对方场上1张卡为对象才能发动。那些卡破坏。
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
-- 筛选‘奈芙提斯’字段（0x11f）且表侧表示的卡，作为自己场上可被选择的对象。
function c50847759.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x11f)
end
-- 取对象效果的发动判定与选目标阶段：发动时检查双方场上是否存在合法对象；若为连锁处理中则不可再选对象。
function c50847759.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1张表侧表示的‘奈芙提斯’字段卡可以作为对象（排除效果发动者自身）。
	if chk==0 then return Duel.IsExistingTarget(c50847759.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上是否存在1张卡可以作为对象（任意卡均可）。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示操作者选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张表侧表示的‘奈芙提斯’卡作为对象（排除效果发动者自身）。
	local g1=Duel.SelectTarget(tp,c50847759.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 再次提示操作者选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为对象（任意卡均可）。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息：确定以合并后的对象组为破坏对象，数量为2，分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果处理阶段：取得连锁选择的对象，筛掉已脱离关系或无法被该效果影响的卡，剩下的全部破坏。
function c50847759.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理时记录的对象卡集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 以‘效果’的原因为原因，将这些对象卡全部破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
