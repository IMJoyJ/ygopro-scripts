--DDD深淵王ビルガメス
-- 效果：
-- 「DD」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把2只卡名不同的「DD」灵摆怪兽在自己的灵摆区域放置，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
-- ②：连接召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。从自己的额外卡组·墓地把1只「DD」怪兽守备表示特殊召唤。
function c9024198.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要2只「DD」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xaf),2)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把2只卡名不同的「DD」灵摆怪兽在自己的灵摆区域放置，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9024198,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,9024198)
	e1:SetTarget(c9024198.settg)
	e1:SetOperation(c9024198.setop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被对方怪兽的攻击或者对方的效果破坏的场合才能发动。从自己的额外卡组·墓地把1只「DD」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9024198,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,9024199)
	e2:SetCondition(c9024198.spcon)
	e2:SetTarget(c9024198.sptg)
	e2:SetOperation(c9024198.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可放置到灵摆区的「DD」灵摆怪兽
function c9024198.setfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- ①效果的发动准备与可行性检测（检查灵摆区是否有2个空位，以及卡组中是否存在至少2种不同卡名的「DD」灵摆怪兽）
function c9024198.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足条件的「DD」灵摆怪兽
	local g=Duel.GetMatchingGroup(c9024198.setfilter,tp,LOCATION_DECK,0,nil)
	-- 检查自己的两个灵摆区域是否都空置可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		and g:GetClassCount(Card.GetCode)>=2 end
	-- 设置效果处理时的操作信息为：给与玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- ①效果的处理：适用不能特殊召唤「DD」以外怪兽的限制，并将卡组中2只卡名不同的「DD」灵摆怪兽放置到灵摆区，之后自己受到1000伤害
function c9024198.setop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把2只卡名不同的「DD」灵摆怪兽在自己的灵摆区域放置，自己受到1000伤害。这个效果的发动后，直到回合结束时自己不是「DD」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c9024198.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤「DD」以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
	-- 检查两个灵摆区域是否依然可用，若有任意一个不可用则不处理后续效果
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) or not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 重新获取卡组中满足条件的「DD」灵摆怪兽
	local g=Duel.GetMatchingGroup(c9024198.setfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组中选择2张卡名不同的「DD」灵摆怪兽
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	local tc1=g1:GetFirst()
	local tc2=g1:GetNext()
	-- 将第一张选中的灵摆怪兽表侧表示放置到灵摆区域
	if Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,false) then
		-- 将第二张选中的灵摆怪兽表侧表示放置到灵摆区域
		if Duel.MoveToField(tc2,tp,tp,LOCATION_PZONE,POS_FACEUP,false) then
			-- 受到1000点效果伤害
			Duel.Damage(tp,1000,REASON_EFFECT)
			tc2:SetStatus(STATUS_EFFECT_ENABLED,true)
		end
		tc1:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end
-- 限制只能特殊召唤「DD」怪兽
function c9024198.splimit(e,c)
	return not c:IsSetCard(0xaf)
end
-- ②效果的发动条件：连接召唤的这张卡在怪兽区域被对方的效果破坏或被对方怪兽攻击破坏
function c9024198.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 检查是否是被对方的效果破坏，或者是被对方控制的怪兽攻击破坏
		and (c:IsReason(REASON_EFFECT) and rp==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
end
-- 过滤额外卡组或墓地中可以守备表示特殊召唤的「DD」怪兽
function c9024198.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查若目标在墓地，则自己场上需要有可用的怪兽区域
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 检查若目标在额外卡组，则需要有可用于从额外卡组特殊召唤该怪兽的区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的发动准备与可行性检测（检查额外卡组或墓地是否存在可特殊召唤的「DD」怪兽）
function c9024198.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组或墓地是否存在至少1只满足特殊召唤条件的「DD」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9024198.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息为：从额外卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- ②效果的处理：从额外卡组或墓地选择1只「DD」怪兽守备表示特殊召唤
function c9024198.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组或墓地（受墓地限制卡影响）选择1只满足条件的「DD」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9024198.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
