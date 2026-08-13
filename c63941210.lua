--壊星壊獣ジズキエル
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：只以卡1张为对象的魔法·陷阱·怪兽的效果发动时，把自己·对方场上3个坏兽指示物取除才能发动。那个效果无效。那之后，可以把场上1张卡破坏。
function c63941210.initial_effect(c)
	-- 设定场上唯一性限制：自己场上主要怪兽区只能有1只表侧表示的「坏兽」怪兽存在
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c63941210.spcon)
	e1:SetTarget(c63941210.sptg)
	e1:SetOperation(c63941210.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c63941210.spcon2)
	c:RegisterEffect(e2)
	-- ④：只以卡1张为对象的魔法·陷阱·怪兽的效果发动时，把自己·对方场上3个坏兽指示物取除才能发动。那个效果无效。那之后，可以把场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63941210,0))  --"发动无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c63941210.discon)
	e3:SetCost(c63941210.discost)
	e3:SetTarget(c63941210.distg)
	e3:SetOperation(c63941210.disop)
	c:RegisterEffect(e3)
end
c63941210.mentioned_counter={
	[0x37]=true,
}
-- 过滤函数：判断对方场上的怪兽能否被解放且解放后对方场上存在可用怪兽区
function c63941210.spfilter(c,tp)
	-- 判断该卡能否因特殊召唤被解放，且其离开后对方场上还有可用的主要怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤条件：检查对方场上是否存在可解放且解放后有空位的怪兽
function c63941210.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在至少1只满足解放条件的怪兽
	return Duel.IsExistingMatchingCard(c63941210.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤目标处理：从对方场上选择1只要解放的怪兽并记录下来
function c63941210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得对方场上所有满足解放条件的怪兽
	local g=Duel.GetMatchingGroup(c63941210.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作：解放之前选中的对方怪兽
function c63941210.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选中的对方怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：判断卡是否为表侧表示的「坏兽」怪兽
function c63941210.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤条件2：自己场上存在可用的主要怪兽区，且对方场上有表侧表示的「坏兽」怪兽
function c63941210.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c63941210.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 发动条件：自身未被战斗破坏，且当前连锁的效果只以1张卡为对象、可以被无效
function c63941210.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁的效果所取的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象只有1张卡且该连锁的效果可以被无效
	return tg and tg:GetCount()==1 and Duel.IsChainDisablable(ev)
end
-- 代价：把自己·对方场上3个坏兽指示物取除作为发动代价
function c63941210.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以取除的3个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 把双方场上合计3个坏兽指示物取除作为代价
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 目标处理：设置当前连锁的操作信息为无效该连锁的效果
function c63941210.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁要无效发动的那个效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 操作：使那个发动的效果无效，然后可以破坏场上1张卡
function c63941210.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上存在的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 使该连锁的效果无效，无效成功且场上有卡时询问玩家是否破坏场上1张卡
	if Duel.NegateEffect(ev) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(63941210,1)) then  --"是否破坏场上1张卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 显示选中的卡成为破坏对象的动画
		Duel.HintSelection(tg)
		-- 以效果原因破坏选中的1张卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
