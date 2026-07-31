--海亀壊獣ガメシエル
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：对方把「海龟坏兽 加美西耶勒」以外的魔法·陷阱·怪兽的效果发动时，把自己·对方场上2个坏兽指示物取除才能发动。那个发动无效并除外。
function c55063751.initial_effect(c)
	-- 在自己场上只能有1只表侧表示的「坏兽」怪兽存在
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,1)
	e1:SetCondition(c55063751.spcon)
	e1:SetTarget(c55063751.sptg)
	e1:SetOperation(c55063751.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetTargetRange(POS_FACEUP_ATTACK,0)
	e2:SetCondition(c55063751.spcon2)
	c:RegisterEffect(e2)
	-- ④：对方把「海龟坏兽 加美西耶勒」以外的魔法·陷阱·怪兽的效果发动时，把自己·对方场上2个坏兽指示物取除才能发动。那个发动无效并除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55063751,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c55063751.negcon)
	e3:SetCost(c55063751.negcost)
	-- 设置发动无效并除外的目标（Target）声明
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c55063751.negop)
	c:RegisterEffect(e3)
end
c55063751.mentioned_counter={
	[0x37]=true,
}
-- 特殊召唤素材过滤：必须可被解放，且解放后不影响怪兽格数量
function c55063751.spfilter(c,tp)
	-- 检查卡片是否可因特殊召唤被解放，且解放后对方场上有可用怪兽格
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤条件：对方场上存在符合解放条件的怪兽
function c55063751.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上是否存在满足解放条件的怪兽
	return Duel.IsExistingMatchingCard(c55063751.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤目标选择：选择对方场上1只怪兽解放
function c55063751.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有符合解放条件的怪兽
	local g=Duel.GetMatchingGroup(c55063751.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 发送选择要解放卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤操作：解放选中的怪兽
function c55063751.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽因特殊召唤而解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤条件：对方场上表侧表示的「坏兽」怪兽
function c55063751.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤条件：自己场上有空格且对方场上有表侧表示的「坏兽」怪兽
function c55063751.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c55063751.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 发动条件：对方发动非「海龟坏兽 加美西耶勒」的效果且该效果可被无效
function c55063751.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查发动效果的卡非同名卡且该连锁发动作有效性可被无效
	return not re:GetHandler():IsCode(55063751) and Duel.IsChainNegatable(ev)
end
-- 发动Cost：取除双方场上2个坏兽指示物
function c55063751.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否能取除2个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 从双方场上取除2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 效果处理：使效果的发动无效并除外
function c55063751.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使效果的发动无效，并确认该卡仍与连锁相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动的卡表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
