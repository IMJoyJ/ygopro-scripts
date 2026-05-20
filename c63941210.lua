--壊星壊獣ジズキエル
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：只以卡1张为对象的魔法·陷阱·怪兽的效果发动时，把自己·对方场上3个坏兽指示物取除才能发动。那个效果无效。那之后，可以把场上1张卡破坏。
function c63941210.initial_effect(c)
	-- 限制自己场上只能有1只表侧表示的「坏兽」怪兽存在
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
-- 定义特殊召唤规则所需的解放怪兽过滤函数
function c63941210.spfilter(c,tp)
	-- 检查怪兽是否可以因特殊召唤而解放，且解放后对方场上是否有可用的怪兽区域
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 定义特殊召唤到对方场上的规则特召条件函数
function c63941210.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在可以解放来特殊召唤此卡的怪兽
	return Duel.IsExistingMatchingCard(c63941210.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 定义特殊召唤到对方场上的规则特召目标选择函数
function c63941210.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足解放条件的怪兽
	local g=Duel.GetMatchingGroup(c63941210.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤到对方场上的规则特召操作函数
function c63941210.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的对方场上的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤对方场上表侧表示的「坏兽」怪兽
function c63941210.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 定义特殊召唤到自己场上的规则特召条件函数
function c63941210.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空余的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c63941210.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 定义无效效果的发动条件函数
function c63941210.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前发动效果的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查效果是否只以1张卡为对象，且该效果可以被无效
	return tg and tg:GetCount()==1 and Duel.IsChainDisablable(ev)
end
-- 定义无效效果的发动代价函数
function c63941210.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断场上是否能取除3个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,3,REASON_COST) end
	-- 从场上取除3个坏兽指示物作为发动代价
	Duel.RemoveCounter(tp,1,1,0x37,3,REASON_COST)
end
-- 定义无效效果的发动目标函数
function c63941210.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明该效果的处理包含使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义无效效果的效果处理函数
function c63941210.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 若成功使效果无效，且场上有卡存在，则询问玩家是否选择进行破坏
	if Duel.NegateEffect(ev) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(63941210,1)) then  --"是否破坏场上1张卡？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 给选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 破坏选中的卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
