--ブラックフェザー・アサルト・ドラゴン
-- 效果：
-- 同调怪兽调整＋调整以外的怪兽1只以上
-- 这张卡用同调召唤以及以下方法才能特殊召唤。
-- ●从自己的场上（表侧表示）·墓地把同调怪兽调整1只和「黑翼龙」1只除外的场合可以从额外卡组特殊召唤。
-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
-- ②：对方回合，把有黑羽指示物4个以上放置的这张卡解放才能发动。场上的卡全部破坏。
function c73218989.initial_effect(c)
	-- 注册卡片关联密码，表示本卡效果中提到了「黑翼龙」（卡号9012916）
	aux.AddCodeList(c,9012916)
	c:EnableCounterPermit(0x10)
	-- 添加同调召唤手续：同调怪兽调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡用同调召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制此卡只能通过同调召唤（或后续设定的特殊召唤规则）进行特殊召唤
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
	-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c73218989.regop)
	c:RegisterEffect(e3)
	-- ①：每次对方把怪兽的效果发动，给这张卡放置1个黑羽指示物，给与对方700伤害。
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
-- 过滤自身特殊召唤所需素材的条件：在场上表侧表示存在或在墓地存在，且可以作为Cost除外
function c73218989.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost()
end
-- 过滤自身特殊召唤所需素材1的条件：同调怪兽调整
function c73218989.mfilter1(c)
	return c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)
end
-- 过滤自身特殊召唤所需素材2的条件：卡名为「黑翼龙」（卡号9012916）
function c73218989.mfilter2(c)
	return c:IsCode(9012916)
end
-- 检查选取的素材组合是否满足特殊召唤条件（包含额外卡组出场位置检查和双卡组合判定）
function c73218989.fselect(g,c,tp)
	-- 检查将选取的素材除外后是否有可用的额外怪兽区域，且选取的两张卡是否分别满足“同调怪兽调整”和“黑翼龙”
	return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and aux.gffcheck(g,c73218989.mfilter1,nil,c73218989.mfilter2,nil)
end
-- 自身特殊召唤规则的Condition函数：检查场上·墓地是否存在满足条件的素材组合
function c73218989.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上（表侧表示）和墓地中所有可以作为Cost除外的卡片组
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c73218989.fselect,2,2,c,tp)
end
-- 自身特殊召唤规则的Target函数：让玩家选择要除外的两张素材卡，并将其保存在LabelObject中
function c73218989.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上（表侧表示）和墓地中所有可以作为Cost除外的卡片组
	local g=Duel.GetMatchingGroup(c73218989.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c73218989.fselect,true,2,2,c,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 自身特殊召唤规则的Operation函数：将选取的素材卡片除外，完成特殊召唤
function c73218989.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选取的素材卡片以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 效果①的辅助注册函数：在对方发动怪兽效果时，给自身注册一个单次连锁内有效的Flag标记
function c73218989.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsActiveType(TYPE_MONSTER) then
		e:GetHandler():RegisterFlagEffect(73218989,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- 效果①的Condition函数：检查是否是对方发动的怪兽效果，且自身已注册对应的Flag标记
function c73218989.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查发动效果的玩家是对方、对方生命值大于0、自身带有Flag标记且发动的效果是怪兽效果
	return ep~=tp and Duel.GetLP(1-tp)>0 and c:GetFlagEffect(73218989)~=0 and re:IsActiveType(TYPE_MONSTER)
end
-- 效果①的Operation函数：给这张卡放置1个黑羽指示物，并给与对方700伤害
function c73218989.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x10,1)
	-- 以效果伤害为原因给与对方玩家700点伤害
	Duel.Damage(1-tp,700,REASON_EFFECT)
end
-- 效果②的Condition函数：检查当前是否为对方回合，且自身未被战斗破坏
function c73218989.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方，且自身没有处于战斗破坏状态
	return Duel.GetTurnPlayer()==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的Cost函数：检查自身是否可以解放且放置有4个以上的黑羽指示物，并在发动时将自身解放
function c73218989.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:GetCounter(0x10)>=4 end
	-- 将自身作为Cost解放
	Duel.Release(c,REASON_COST)
end
-- 效果②的Target函数：检查场上是否存在除自身以外的卡，并设置破坏所有场上卡的操作信息
function c73218989.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认场上是否存在至少1张除自身以外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有的卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁处理的操作信息，分类为破坏，目标为场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的Operation函数：获取场上所有的卡并将其全部破坏
function c73218989.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 以效果原因为原因破坏选取的卡片组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
