--マシマシュマロン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方回合，自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有「光之黄金柜」存在，这张卡不会被战斗破坏，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：这张卡被效果破坏的场合才能发动。除这张卡外的自己的手卡·卡组·墓地·除外状态的1只「增量棉花糖」特殊召唤，给与对方1000伤害。
local s,id,o=GetID()
-- 注册存在「光之黄金柜」时的战破抗性、嘲讽攻击、对方回合手卡特召、以及被效果破坏特召「棉花糖」并烧血的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「光之黄金柜」（卡片密码：79791878）
	aux.AddCodeList(c,79791878)
	-- 注册在自己场上存在「光之黄金柜」时此卡不会被战斗破坏的持续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 注册在自己场上存在「光之黄金柜」时对方只能选择此卡作为攻击对象的场地影响效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.indescon)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	-- ①：对方回合，自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果破坏的场合才能发动。从自己的手卡·卡组·墓地·除外状态把这只怪兽以外的1只「棉花糖」特殊召唤，给予对方1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤「增量棉花糖」"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 场上表侧表示存在的「光之黄金柜」的过滤条件
function s.indesfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 判断自己场上是否存在表侧表示的「光之黄金柜」
function s.indescon(e)
	-- 确认场上是否有「光之黄金柜」
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 限制对方只能选择此卡作为攻击对象，不能选择其他怪兽
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 判断当前是否定处于对方回合且自己场上存在「光之黄金柜」
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认上述条件在当前发动时点是否被满足
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) and Duel.GetTurnPlayer()~=tp
end
-- 手卡特召效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有空余的怪兽格以供特殊召唤
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置操作信息为将这张卡自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手卡特召效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将手手中的此卡以表侧表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 确认此卡是被效果破坏送去墓地或除外的
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 手卡、卡组、墓地或除外状态的可特殊召唤的「棉花糖」的过滤条件
function s.spfilter2(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
-- 被效果破坏时特召其他「棉花糖」效果的发动准备与合法性检查
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 确认自己场上拥有可用于特召的怪兽格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡/卡组/墓地/除外状态是否存在可以特殊召唤的另一只「棉花糖」
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息为特殊召唤另一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤另一只「棉花糖」并给予对方1000伤害效果的执行
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否有空闲怪兽格，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择需要特殊召唤的「棉花糖」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡、卡组、墓地或除外状态中选择1只「棉花糖」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 若「棉花糖」特殊召唤成功，则继续处理后续的伤害效果
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 给予对方玩家1000点生命值伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
