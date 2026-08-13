--椿姫ティタニアル
-- 效果：
-- ①：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只表侧表示的植物族怪兽解放才能发动。那个发动无效并破坏。
function c11819616.initial_effect(c)
	-- ①：场上的卡为对象的魔法·陷阱·怪兽的效果发动时，把自己场上1只表侧表示的植物族怪兽解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11819616,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c11819616.discon)
	e2:SetCost(c11819616.discost)
	e2:SetTarget(c11819616.distg)
	e2:SetOperation(c11819616.disop)
	c:RegisterEffect(e2)
end
-- 发动条件的判定：自己怪兽不是战斗破坏确定状态；对方发动的效果必须为取对象效果；该连锁的对象中存在场上的卡；并且该连锁的发动可以被无效。
function c11819616.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从当前连锁（ev）中获取对方发动的效果所取的对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查获取到的对象卡组中是否存在至少1张在场上的卡，并且该连锁的发动能够被无效，二者同时满足时条件成立。
	return tg and tg:IsExists(Card.IsOnField,1,nil) and Duel.IsChainNegatable(ev)
end
-- 代价过滤条件：选择自己场上表侧表示、种族为植物族，且不是战斗破坏确定状态的怪兽作为解放对象。
function c11819616.costfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价的支付处理：先检查是否能从自己场上解放1只符合条件的植物族怪兽；可以则选择1只并解放，作为效果发动的COST。
function c11819616.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 询问是否满足代价：检查自己场上是否存在至少1只符合costfilter条件的可解放的植物族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c11819616.costfilter,1,nil) end
	-- 从自己场上选择1只符合costfilter条件的可解放的怪兽作为要解放的代价。
	local sg=Duel.SelectReleaseGroup(tp,c11819616.costfilter,1,1,nil)
	-- 将选择的那只植物族怪兽解放，解放原因为COST（代价）。
	Duel.Release(sg,REASON_COST)
end
-- 效果发动时的目标设定：确定要发动无效效果，并尽可能追加破坏效果；同时登记操作信息，用于后续处理及各种连锁检测。
function c11819616.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记“使对方效果的发动无效”这一操作信息，对象为当前连锁中发动的效果（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方效果发动的那张卡可被破坏且与那个效果仍有联系，则登记“破坏”这一操作信息，对象同样为eg，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效对方的效果发动，若成功且效果发动的那张卡仍与连锁相关，则将那张卡破坏。
function c11819616.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该连锁的发动是否被成功无效，且对方效果发动的那张卡仍然与那个效果保持联系（没有离场或失联）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的效果所在的那张卡以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
