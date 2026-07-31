--壊星壊獣ジズキエル
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：只以卡1张为对象的魔法·陷阱·怪兽的效果发动时，把自己·对方场上3个坏兽指示物取除才能发动。那个效果无效。那之后，可以把场上1张卡破坏。
function c63941210.initial_effect(c)
	-- 场上唯一存在限制：自己场上只能有1只「坏兽」怪兽表侧表示存在
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
	-- ④：只以卡1张为对象的魔法·陷阱·怪兽的效果发动时，把自己·对方场上3个坏兽指示物去除才能发动。那个效果无效。那之后，可以把场上1张卡破坏。
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
-- 对方场上特召解放过滤条件：可以为特殊召唤而解放且解放后对方怪兽区有空位
function c63941210.spfilter(c,tp)
	-- 确认怪兽可因特召解放且解放后能为玩家在对方场上特殊召唤提供空位
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 对方场上规则特召条件：对方场上存在可解放的怪兽
function c63941210.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在满足特召解放条件的怪兽
	return Duel.IsExistingMatchingCard(c63941210.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 对方场上规则特召目标选择：选择对方场上1只怪兽解放
function c63941210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足特召解放条件的怪兽
	local g=Duel.GetMatchingGroup(c63941210.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 对方场上规则特召Cost处理：解放选中的对方怪兽
function c63941210.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的对方怪兽作为特召Cost解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 坏兽卡过滤条件：表侧表示且为「坏兽」卡
function c63941210.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 自己场上规则特召条件：自己主要怪兽区域有空位且对方场上有「坏兽」怪兽
function c63941210.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c63941210.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 无效效果发动条件：连锁中的效果为恰好以1张卡为对象的效果
function c63941210.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁中效果所选择的对象卡片集合
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象数量恰好为1且该连锁效果可以被无效
	return tg and tg:GetCount()==1 and Duel.IsChainDisablable(ev)
end
-- 无效效果Cost处理：去除场上3个坏兽指示物
function c63941210.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：双方场上是否存在至少3个可去除的坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 从双方场上去除3个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 无效效果发动准备：设置无效连锁效果的操作信息
function c63941210.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：无效该连锁效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果处理：无效连锁效果，并可选择破坏场上1张卡
function c63941210.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 成功无效效果且场上有卡时，询问玩家是否破坏场上1张卡
	if Duel.NegateEffect(ev) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(63941210,1)) then  --"是否破坏场上1张卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 高亮显示选中的目标破坏卡
		Duel.HintSelection(tg)
		-- 将选中的卡破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
