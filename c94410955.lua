--見えざる神ゼノ
-- 效果：
-- 「不可见之手」怪兽×3
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。把对方的额外卡组的里侧的卡随机2张确认。可以从那之中选1张在自己场上特殊召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：融合召唤的这张卡被对方的效果破坏的场合才能发动。选对方场上的怪兽任意数量，得到那些控制权。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 设置融合召唤手续：需要3只满足过滤条件s.ffilter的怪兽作为素材。
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段才能发动。把对方的额外卡组的里侧的卡随机2张确认。可以从那之中选1张在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被对方的效果破坏的场合才能发动。选对方场上的怪兽任意数量，得到那些控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"获得控制权"
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：属于「不可见之手」字段的怪兽。
function s.ffilter(c)
	return c:IsFusionSetCard(0x1d3)
end
-- 效果①的发动条件：自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 效果①的发动准备（Target）：检查对方额外卡组是否有至少2张里侧卡片。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方额外卡组是否存在至少2张里侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_EXTRA,2,nil) end
end
-- 特殊召唤过滤条件：可以被特殊召唤，且自己场上有可供额外卡组怪兽出场的空格。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有可供该额外卡组怪兽特殊召唤的可用区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的效果处理（Operation）：随机确认对方额外卡组2张里侧卡，并可选择其中1张特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方额外卡组中所有里侧表示的卡。
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA):Filter(Card.IsFacedown,nil)
	local g=hg:RandomSelect(tp,2)
	if g:GetCount()<1 then return end
	-- 给发动效果的玩家确认选中的2张卡。
	Duel.ConfirmCards(tp,g)
	if g:IsExists(s.spfilter,1,nil,e,tp)
		-- 询问玩家是否要进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选中的卡在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的适用对象过滤：自身或者与自身进行战斗的怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果③的发动条件：融合召唤的这张卡在自己怪兽区因对方的效果被破坏。
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReason(REASON_EFFECT)
end
-- 效果③的发动准备（Target）：检查对方场上是否有可以改变控制权的怪兽，并设置操作信息。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以改变控制权的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以改变控制权的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：改变控制权，预计数量为至少1张。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果③的效果处理（Operation）：选择对方场上任意数量可以改变控制权的怪兽，得到那些控制权。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上主要怪兽区域的可用空格数。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1到当前可用空格数数量的可以改变控制权的怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,ct,nil)
	if g:GetCount()>0 then
		-- 为选中的怪兽显示被选为效果对象的动画效果。
		Duel.HintSelection(g)
		-- 获得选中怪兽的控制权。
		Duel.GetControl(g,tp)
	end
end
