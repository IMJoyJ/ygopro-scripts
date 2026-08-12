--伍世壊砕心
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只调整或者同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把光属性怪兽特殊召唤的场合，可以再选持有那个攻击力以下的攻击力的对方场上1只怪兽破坏。
-- ②：自己场上的「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动时的特殊召唤及破坏效果）和②效果（墓地代破效果）。
function s.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」（卡号56099748）加入该卡的关联卡片密码列表中。
	aux.AddCodeList(c,56099748)
	-- ①：以自己墓地1只调整或者同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把光属性怪兽特殊召唤的场合，可以再选持有那个攻击力以下的攻击力的对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「维萨斯-斯塔弗罗斯特」或者攻击力1500/守备力2100的怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己墓地中可以特殊召唤的调整或同调怪兽。
function s.spfilter(c,e,tp)
	local b1=c:IsType(TYPE_TUNER)
	local b2=c:IsType(TYPE_SYNCHRO)
	return (b1 or b2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：筛选对方场上表侧表示且攻击力在指定数值以下的怪兽。
function s.atkfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- ①效果的发动准备，处理取对象判定、检查怪兽区域空格以及墓地中是否存在合法的特殊召唤对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查发动时自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的调整或同调怪兽可以作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤该对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的执行函数，处理特殊召唤，并判定是否满足追加破坏对方场上怪兽的条件。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的特殊召唤对象。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否仍与效果相关，并尝试将其以表侧表示特殊召唤，若特殊召唤失败则结束处理。
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检查特殊召唤的怪兽是否为光属性，且对方场上是否存在持有该怪兽攻击力以下攻击力的怪兽。
	if tc:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
		-- 询问玩家是否选择发动追加的破坏效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选对方怪兽破坏？"
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择对方场上1只持有该特殊召唤怪兽攻击力以下攻击力的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行（防止错时点）。
		Duel.BreakEffect()
		-- 显式显示被选择破坏的怪兽。
		Duel.HintSelection(g)
		-- 破坏选中的对方怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤函数：筛选自己场上因战斗或效果被破坏的「维萨斯-斯塔弗罗斯特」或攻击力1500/守备力2100的怪兽。
function s.repfilter(c,tp)
	local b1=c:IsCode(56099748)
	local b2=c:IsAttack(1500) and c:IsDefense(2100)
	return not c:IsReason(REASON_REPLACE) and c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and (b1 or b2)
end
-- ②效果的代替破坏判定，检查墓地的这张卡是否可以除外，以及是否有符合条件的怪兽被破坏。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否选择使用此卡代替破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判定被破坏的怪兽是否属于可以被代替破坏的范围。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的代替破坏执行函数，将墓地的这张卡除外。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外，作为代替破坏的处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
