--海亀壊獣ガメシエル
-- 效果：
-- ①：这张卡可以把对方场上1只怪兽解放，从手卡往对方场上攻击表示特殊召唤。
-- ②：对方场上有「坏兽」怪兽存在的场合，这张卡可以从手卡攻击表示特殊召唤。
-- ③：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ④：对方把「海龟坏兽 加美西耶勒」以外的魔法·陷阱·怪兽的效果发动时，把自己·对方场上2个坏兽指示物取除才能发动。那个发动无效并除外。
function c55063751.initial_effect(c)
	-- 设定场上唯一性限制：自己场上只能有1只表侧表示存在的「坏兽」系列怪兽（即效果③的规则实现）
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
	-- 设置无效并除外的通用目标选择函数（检查该连锁的发动能否被无效，若在墓地发动则追加墓地操作分类）
	e3:SetTarget(aux.nbtg)
	e3:SetOperation(c55063751.negop)
	c:RegisterEffect(e3)
end
c55063751.mentioned_counter={
	[0x37]=true,
}
-- 定义特殊召唤过滤器：筛选对方场上可以被解放、且解放后自己能有可用怪兽区放置这张卡的怪兽
function c55063751.spfilter(c,tp)
	-- 返回该卡能否因特殊召唤而被解放，以及解放该卡后对方场上（这张卡的放置位置）是否有空余的怪兽区
	return c:IsReleasable(REASON_SPSUMMON) and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 特殊召唤手续①的发动条件：确认对方场上存在至少1只满足解放条件的怪兽
function c55063751.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方怪兽区是否存在至少1张满足过滤器（可解放且解放后有空格）的卡
	return Duel.IsExistingMatchingCard(c55063751.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
-- 特殊召唤手续①的目标选择：从对方场上选择1只要解放的怪兽并暂存到效果标签中，若放弃选择则无法特殊召唤
function c55063751.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取对方场上所有满足解放过滤条件的怪兽组成可选卡组
	local g=Duel.GetMatchingGroup(c55063751.spfilter,tp,0,LOCATION_MZONE,nil,tp)
	-- 向玩家显示「请选择要解放的卡」的选卡提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续①的处理：将之前选择的对方场上怪兽解放，完成这张卡在对方场上的特殊召唤前置操作
function c55063751.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因将选定的怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义过滤器：筛选表侧表示存在的「坏兽」系列怪兽
function c55063751.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤手续②的发动条件：自己怪兽区有空位，且对方场上有「坏兽」怪兽表侧表示存在
function c55063751.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区是否有可用空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查对方场上存在至少1只表侧表示的「坏兽」怪兽
		and Duel.IsExistingMatchingCard(c55063751.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 无效效果的发动条件：必须是对方发动的效果（自己发动或这张卡被战斗破坏时不适用），且该效果不是「海龟坏兽 加美西耶勒」本身的发动，同时该连锁可以被无效
function c55063751.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 返回发动的效果卡不是「海龟坏兽 加美西耶勒」本身，且该连锁的发动可以被无效
	return not re:GetHandler():IsCode(55063751) and Duel.IsChainNegatable(ev)
end
-- 无效效果的代价：检查能否取除指示物，若可以则将自己·对方场上2个坏兽指示物取除作为发动代价
function c55063751.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（可行性检查阶段）时，检查自己·对方场上是否能以代价原因取除2个坏兽指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 实际执行代价：从自己·对方场上取除2个坏兽指示物
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 无效效果的处理：使那个效果的发动无效，若发动的卡仍与效果相关联则将其除外
function c55063751.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁的发动无效，并确认发动该效果的卡仍与效果相关联（即仍在原位置可处理）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的卡以表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
