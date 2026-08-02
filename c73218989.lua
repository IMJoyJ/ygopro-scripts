--ブラックフェザー・アサルト・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的怪兽1只以上
-- 这张卡用同调召唤以及以下方法才能特殊召唤。
-- ●从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑翼龙」1只除外的场合可以从额外卡组特殊召唤。
-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
-- ②：对方回合，把有黑羽指示物4个以上放置的这张卡解放才能发动。场上的卡全部破坏。
function c73218989.initial_effect(c)
	-- 记录卡片上记载着「黑翼龙」
	aux.AddCodeList(c,9012916)
	c:EnableCounterPermit(0x10)
	-- 为这张卡添加同调召唤手续：需要同调怪兽调整和调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡用同调召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制只能通过同调召唤或者特定方式特殊召唤
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- ●从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑翼龙」1只除外的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73218989,0))  --"把「黑翼龙」除外特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c73218989.spcon)
	e2:SetTarget(c73218989.sptg)
	e2:SetOperation(c73218989.spop)
	c:RegisterEffect(e2)
	-- ①：每次对方把怪兽的效果发动
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c73218989.regop)
	c:RegisterEffect(e3)
	-- 给这张卡放置1个黑羽指示物，给与对方700伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c73218989.damcon)
	e4:SetOperation(c73218989.damop)
	c:RegisterEffect(e4)
	-- ②：对方回合，把有黑羽指示物4个以上放置的这张卡解放才能发动。场上的卡全部破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(73218989,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetCondition(c73218989.descon)
	e5:SetCost(c73218989.descost)
	e5:SetTarget(c73218989.destg)
	e5:SetOperation(c73218989.desop)
	c:RegisterEffect(e5)
end
c73218989.material_type=TYPE_SYNCHRO
c73218989.mentioned_counter={
	[0x10]=true,
}
-- 检查卡片是否为表侧表示且能作为代价除外
function c73218989.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
-- 检查卡片是否为同调怪兽调整
function c73218989.mfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)
end
-- 检查卡片是否为「黑翼龙」
function c73218989.mfilter2(c)
	return c:IsCode(9012916)
end
-- 检查除外素材后场上是否有额外怪兽区空位，且素材组合为同调调整和「黑翼龙」
function c73218989.fselect(g,c,tp)
	-- 确保除外后场上有额外怪兽区的空位，并且素材包含同调调整和「黑翼龙」各一只
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and aux.gffcheck(g,c73218989.mfilter1,nil,c73218989.mfilter2,nil)
end
-- 检查是否有满足除外条件的素材组合
function c73218989.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上和墓地可作为代价除外的卡片组
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c73218989.fselect,2,2,c,tp)
end
-- 提示玩家选择作为特殊召唤代价除外的卡并记录选中卡片
function c73218989.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上和墓地能被除外的卡
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c73218989.fselect,true,2,2,c,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将记录的卡片除外并清理缓存
function c73218989.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 作为特殊召唤代价把选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 如果是对方发动怪兽效果则为自身注册一个标记效果
function c73218989.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(73218989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- 检查是否是对方发动了怪兽效果并且该怪兽效果已结算
function c73218989.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为对方发动的怪兽效果且对方生命值大于0
	return ep~=tp and Duel.GetLP(1-tp)>0 and c:GetFlagEffect(73218989)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 给这张卡放置1个黑羽指示物并给与对方700伤害
function c73218989.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x10,1)
	-- 给与对方700伤害
	Duel.Damage(1-tp,700,REASON_EFFECT)
end
-- 检查当前回合是否为对方回合且这张卡未被战斗破坏
function c73218989.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在对方回合并且此卡没有被战斗破坏
	return Duel.GetTurnPlayer()==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查这张卡是否有4个以上的黑羽指示物且能被解放，如果能则将其解放作为代价
function c73218989.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:GetCounter(0x10)>=4 end
	-- 将这张卡解放作为代价
	Duel.Release(c,REASON_COST)
end
-- 检查场上是否存在可以被破坏的卡，并设置包含破坏场上所有卡的操作信息
function c73218989.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在可以被破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有的卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：包含破坏场上所有卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 获取场上所有的卡并将其破坏
function c73218989.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 破坏场上所有的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
