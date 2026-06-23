--マシマシュマロン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方回合，自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有「光之黄金柜」存在，这张卡不会被战斗破坏，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：这张卡被效果破坏的场合才能发动。除这张卡外的自己的手卡·卡组·墓地·除外状态的1只「增量棉花糖」特殊召唤，给与对方1000伤害。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个永续效果和两个诱发效果
function s.initial_effect(c)
	-- 记录该卡与「光之黄金柜」的关联
	aux.AddCodeList(c,79791878)
	-- 只要自己场上有「光之黄金柜」存在，这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 只要自己场上有「光之黄金柜」存在，对方怪兽不能选择其他怪兽作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.indescon)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	-- 对方回合，自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤
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
	-- 这张卡被效果破坏的场合才能发动。除这张卡外的自己的手卡·卡组·墓地·除外状态的1只「增量棉花糖」特殊召唤，给与对方1000伤害
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
-- 过滤函数，用于判断场上是否存在「光之黄金柜」
function s.indesfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 判断条件函数，用于判断是否满足效果发动条件
function s.indescon(e)
	-- 检查自己场上是否存在至少1张「光之黄金柜」
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 攻击限制函数，用于限制对方怪兽不能选择该卡作为攻击对象
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 特殊召唤发动条件函数，用于判断是否满足特殊召唤发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「光之黄金柜」且当前回合不是自己回合
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤目标函数，用于判断是否可以发动特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可用怪兽区
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤执行函数，用于执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 被破坏时发动条件函数，用于判断是否满足破坏效果发动条件
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选可以特殊召唤的「增量棉花糖」
function s.spfilter2(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
-- 特殊召唤目标函数，用于判断是否可以发动特殊召唤
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·卡组·墓地·除外状态是否存在至少1张「增量棉花糖」
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 特殊召唤执行函数，用于执行特殊召唤操作并造成伤害
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「增量棉花糖」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤到场上
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
			-- 给与对方1000伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
