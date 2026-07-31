--ブラックフェザー・アサルト・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的怪兽1只以上
-- 这张卡用同调召唤以及以下方法才能特殊召唤。
-- ●从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑翼龙」1只除外的场合可以从额外卡组特殊召唤。
-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
-- ②：对方回合，把有黑羽指示物4个以上放置的这张卡解放才能发动。场上的卡全部破坏。
function c73218989.initial_effect(c)
	-- 注册关联卡名列表：「黑羽龙」
	aux.AddCodeList(c,9012916)
	c:EnableCounterPermit(0x10)
	-- 设定同调召唤手续：同调怪兽调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 设定特殊召唤限制：这张卡用同调召唤以及规则约定的特殊召唤方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限定只能正规同调召唤或自身规则特召
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- 规则特殊召唤手续：从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑羽龙」1只除外才能额外卡组特殊召唤。
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
	-- ①：每次对方把怪兽的效果发动，标记连锁状态以在结算时放置黑羽指示物并给予伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c73218989.regop)
	c:RegisterEffect(e3)
	-- ①效果结算处理：对方怪兽效果结算时给这张卡放置1个黑羽指示物，给予对方700伤害。
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
-- 特召素材过滤条件：场上表侧表示或墓地中可以除外的卡
function c73218989.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
-- 素材1过滤条件：同调怪兽调整
function c73218989.mfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)
end
-- 素材2过滤条件：「黑羽龙」
function c73218989.mfilter2(c)
	return c:IsCode(9012916)
end
-- 素材组合检查：包含1只同调调整和1只「黑羽龙」，且满足额外怪兽区域空位条件
function c73218989.fselect(g,c,tp)
	-- 判断所选素材组合是否符合特殊召唤及位置要求
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and aux.gffcheck(g,c73218989.mfilter1,nil,c73218989.mfilter2,nil)
end
-- 规则特召发动条件：场上·墓地中存在符合条件的特召素材组合
function c73218989.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上及墓地中所有可除外的素材候选
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c73218989.fselect,2,2,c,tp)
end
-- 规则特召素材选择：选择并保存需要除外的2只素材怪兽
function c73218989.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上及墓地中所有可除外的素材候选
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
-- 规则特召处理：将选中的素材除外以特殊召唤此卡
function c73218989.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的2只素材怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 连锁发动监听处理：对方发动怪兽效果时在此卡注册标记
function c73218989.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(73218989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- ①效果伤害触发条件检查：该连锁由对方怪兽效果发动且包含标记
function c73218989.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足给与700伤害和放置指示物的条件
	return ep~=tp and Duel.GetLP(1-tp)>0 and c:GetFlagEffect(73218989)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果处理：给此卡放置1个黑羽指示物并给予对方700伤害
function c73218989.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x10,1)
	-- 给予对方700效果伤害
	Duel.Damage(1-tp,700,REASON_EFFECT)
end
-- ②效果发动条件检查：处于对方回合且自身未在战斗中破坏
function c73218989.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合且此卡处于正常状态
	return Duel.GetTurnPlayer()==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果发动Cost：解放放置有4个以上黑羽指示物的此卡
function c73218989.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:GetCounter(0x10)>=4 end
	-- 将自身解放作为Cost送去墓地
	Duel.Release(c,REASON_COST)
end
-- ②效果发动准备：设置破坏全场卡片的操作信息
function c73218989.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：场上是否存在除自身以外可破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取全场所有在场卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏全场卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：将场上的卡全部破坏
function c73218989.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取全场所有在场卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 破坏获取到的全场卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
