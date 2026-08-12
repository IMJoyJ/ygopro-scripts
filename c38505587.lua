--マシマシュマロン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方回合，自己场上有「光之黄金柜」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有「光之黄金柜」存在，这张卡不会被战斗破坏，对方怪兽不能选择其他怪兽作为攻击对象。
-- ③：这张卡被效果破坏的场合才能发动。除这张卡外的自己的手卡·卡组·墓地·除外状态的1只「增量棉花糖」特殊召唤，给与对方1000伤害。
local s,id,o=GetID()
-- 初始化效果：注册②的不被战斗破坏和不能成为攻击对象的永续效果、①的对方回合从手卡特殊召唤的诱发即时效果、③的被效果破坏时特殊召唤同名卡并给予伤害的诱发效果
function s.initial_effect(c)
	-- 在此卡上登记「光之黄金柜」的卡名（卡号79791878），表明这张卡记载了该卡名
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
	-- ③：这张卡被效果破坏的场合才能发动。除这张卡外的自己的手卡·卡组·墓地·除外状态的1只「增量棉花糖」特殊召唤，给与对方1000伤害。
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
-- 定义过滤函数：判断卡是否为正面表示的「光之黄金柜」
function s.indesfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- ②效果的适用条件：检查自己场上是否存在正面表示的「光之黄金柜」
function s.indescon(e)
	-- 检查自己场上是否存在至少1张正面表示的「光之黄金柜」
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 「不能选择为攻击对象」效果的适用对象限定为这张卡以外的怪兽
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
-- ①效果的发动条件：自己场上有「光之黄金柜」存在且当前是对方回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上存在正面表示的「光之黄金柜」且当前回合玩家不是自己（即对方回合）
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) and Duel.GetTurnPlayer()~=tp
end
-- ①效果的目标检测：确认这张卡可以从手卡特殊召唤且自己有可用的主要怪兽区
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且自己的主要怪兽区至少有1个可用空格
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置连锁的操作信息：宣告将以特殊召唤分类特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：确认这张卡仍与效果关联后，将其从手卡以正面表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以正面表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的发动条件：这张卡是被效果破坏的
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 定义过滤函数：判断卡是否为这张卡以外的可以被特殊召唤的「增量棉花糖」（手卡·卡组中的或墓地·除外的正面表示卡）
function s.spfilter2(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
-- ③效果的目标检测：确认自己有可用的主要怪兽区且手卡·卡组·墓地·除外中存在可特殊召唤的「增量棉花糖」
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 发动条件检测时，确认自己的主要怪兽区至少有1个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己的手卡·卡组·墓地·除外状态中存在至少1只满足条件的「增量棉花糖」（这张卡除外）
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁的操作信息：宣告将从手卡·卡组·墓地·除外特殊召唤1只怪兽（具体卡在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ③效果的处理：有可用怪兽区时让玩家选择1只「增量棉花糖」特殊召唤，成功后给与对方1000伤害
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区没有可用空格则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地·除外中选择1只「增量棉花糖」（这张卡除外，且选择受王家长眠之谷影响的卡时作无效处理）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 将选择的卡以正面表示特殊召唤，若特殊召唤成功则继续处理
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 以效果伤害给与对方1000点伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
