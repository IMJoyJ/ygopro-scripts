--マジェスペクター・テンペスト
-- 效果：
-- ①：可以把自己场上1只魔法师族·风属性怪兽解放把以下效果发动。
-- ●怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
function c2572890.initial_effect(c)
	-- ①：可以把自己场上1只魔法师族·风属性怪兽解放把以下效果发动。●自己或者对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	-- 特殊召唤无效效果的发动条件：当前不在连锁处理中（无正在处理的连锁）时才能发动，对应“特殊召唤之际才能发动”。
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c2572890.cost)
	e1:SetTarget(c2572890.target1)
	e1:SetOperation(c2572890.activate1)
	c:RegisterEffect(e1)
	-- ①：可以把自己场上1只魔法师族·风属性怪兽解放把以下效果发动。●怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c2572890.condition2)
	e2:SetCost(c2572890.cost)
	e2:SetTarget(c2572890.target2)
	e2:SetOperation(c2572890.activate2)
	c:RegisterEffect(e2)
end
-- 解放素材筛选条件：必须是魔法师族且风属性，并且不是已确定被战斗破坏尚未离场的怪兽。
function c2572890.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价处理整体：从自己场上选取1只满足筛选条件的魔法师族·风属性怪兽解放，以发动效果。
function c2572890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1只满足条件且可解放的魔法师族·风属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2572890.cfilter,1,nil) end
	-- 让玩家选择1张满足条件的魔法师族·风属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c2572890.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为发动效果所需的代价（REASON_COST，视为代价解放）。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤无效侧的目标处理整体：不取对象，将这次特殊召唤的怪兽群设定为操作信息，准备无效并破坏。
function c2572890.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前正要特殊召唤的怪兽群全部标记为无效特殊召唤的对象（CATEGORY_DISABLE_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将当前正要特殊召唤的怪兽群全部标记为破坏对象（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 特殊召唤无效侧的处理整体：实际执行使这次特殊召唤无效，并将那些怪兽破坏。
function c2572890.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 使正在进行的特殊召唤无效化。
	Duel.NegateSummon(eg)
	-- 将因特殊召唤无效而被留在场上的那些怪兽以效果破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 怪兽效果发动无效侧的条件判定整体：仅在连锁中的效果为怪兽效果且可被无效时才能发动。
function c2572890.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被连锁的效果是否为怪兽效果，以及该效果发动是否可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 怪兽效果发动无效侧的目标处理整体：不取对象，设置无效该发动的操作信息；若效果发动者能破坏且与效果关联，则同时设置破坏操作信息。
function c2572890.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该连锁的效果发动标记为无效对象（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：将发动效果的怪兽卡标记为破坏对象（CATEGORY_DESTROY），若它可破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 怪兽效果发动无效侧的处理整体：无效该效果的发动，并破坏其发动者怪兽。
function c2572890.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：效果发动被成功无效，且发动效果的那张卡仍与效果关联时，才执行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏发动效果的那只怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
