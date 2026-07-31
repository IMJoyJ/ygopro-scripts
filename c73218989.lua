--ブラックフェザー・アサルト・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的怪兽1只以上
-- 这张卡用同调召唤以及以下方法才能特殊召唤。
-- ●从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑翼龙」1只除外的场合可以从额外卡组特殊召唤。
-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
-- ②：对方回合，把有黑羽指示物4个以上放置的这张卡解放才能发动。场上的卡全部破坏。
function c73218989.initial_effect(c)
	-- 注册卡片记述列表：记述「黑羽龙」
	aux.AddCodeList(c,9012916)
	c:EnableCounterPermit(0x10)
	-- 设置同调召唤手续：同调怪兽调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 注册特殊召唤限制：非规程同调召唤必须遵循自身的同调召/规则特召条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置苏生限制与特召限制逻辑
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- 从额外卡组的规则特殊召唤：从自己的场地（表侧表示）·墓地把同调怪兽调整1只和「黑羽龙」1只除外，从额外卡组特殊召唤。
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
	-- 连锁诱发标记：对方发动怪兽效果时在连锁中注册标记
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c73218989.regop)
	c:RegisterEffect(e3)
	-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给予对方700伤害。
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
-- 规则特召素材过滤条件：场上表侧表示或墓地中可除外的卡
function c73218989.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
-- 规则特召素材1组过滤条件：同调怪兽调整
function c73218989.mfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)
end
-- 规则特召素材2组过滤条件：「黑羽龙」
function c73218989.mfilter2(c)
	return c:IsCode(9012916)
end
-- 规则特召素材组合检查：从额外卡组特召空位及包含1只同调怪兽调整与1只「黑羽龙」
function c73218989.fselect(g,c,tp)
	-- 判断额外怪兽区域空位与素材组合法性
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and aux.gffcheck(g,c73218989.mfilter1,nil,c73218989.mfilter2,nil)
end
-- 规则特召发动条件检查：场上/墓地是否存在符合条件的素材组合
function c73218989.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上表侧表示及墓地中所有可除外的卡
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c73218989.fselect,2,2,c,tp)
end
-- 规则特召素材选择：由玩家选择1只同调怪兽调整和1只「黑羽龙」除外
function c73218989.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上表侧表示及墓地中所有可除外的卡
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
-- 规则特召效果处理：表侧表示除外选中的2张素材
function c73218989.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以规则特召原因将素材表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 连锁诱发处理：对方发动怪兽效果时给自身注册Flag标记
function c73218989.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(73218989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- ①效果触发条件检查：连锁结算时确认标记存在且发动者为对方怪兽效果
function c73218989.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认效果由对方怪兽发动且自身带有连锁标记
	return ep~=tp and Duel.GetLP(1-tp)>0 and c:GetFlagEffect(73218989)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果处理：放置1个黑羽指示物并给予对方700伤害
function c73218989.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x10,1)
	-- 给予对方700分效果伤害
	Duel.Damage(1-tp,700,REASON_EFFECT)
end
-- ②效果发动条件检查：处于对方回合且自身未被战斗破坏
function c73218989.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为对方回合且此卡未处于战斗破坏状态
	return Duel.GetTurnPlayer()==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果Cost：有4个以上黑羽指示物并将自身解放
function c73218989.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:GetCounter(0x10)>=4 end
	-- 解放此卡
	Duel.Release(c,REASON_COST)
end
-- ②效果发动准备：设置全场卡片破坏的操作信息
function c73218989.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：场上是否存在其他卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏场上的全部卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：破坏场上的全部卡
function c73218989.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
