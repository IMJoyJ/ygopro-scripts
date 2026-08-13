--ウェルカム・ラビュリンス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「拉比林斯迷宫」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是恶魔族怪兽不能从卡组·额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡在自己场上盖放。这个效果在这张卡送去墓地的回合不能发动。
function c5380979.initial_effect(c)
	-- ①：从卡组把1只「拉比林斯迷宫」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是恶魔族怪兽不能从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5380979,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,5380979)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c5380979.target)
	e1:SetOperation(c5380979.activate)
	c:RegisterEffect(e1)
	-- ②：这个回合没有送去墓地的这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5380979,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O+CATEGORY_SSET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5380980)
	e2:SetCondition(c5380979.setcon)
	e2:SetTarget(c5380979.settg)
	e2:SetOperation(c5380979.setop)
	c:RegisterEffect(e2)
end
-- 过滤器：筛选卡组中持有「拉比林斯迷宫」字段且能被当前效果特殊召唤的怪兽。
function c5380979.spfilter(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：确认自己主要怪兽区有空位，并且卡组中存在满足特殊召唤条件的「拉比林斯迷宫」怪兽。
function c5380979.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否存在空位，作为①效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只持有「拉比林斯迷宫」字段且可被当前效果特殊召唤的怪兽，作为①效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c5380979.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次操作信息：预定从卡组特殊召唤1只怪兽，用于让其他卡（如星尘龙等）能正确响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1只「拉比林斯迷宫」怪兽特殊召唤；然后调用白银之城联动破坏判定；若这张卡是以魔法·陷阱卡发动方式使用的，则给自己附加直到下个回合结束为止、非恶魔族怪兽不能从卡组·额外卡组特殊召唤的自肃效果。
function c5380979.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=0
	-- 处理时再次确认主要怪兽区有空位，才能执行从卡组特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，要求玩家从卡组中选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组中选择1只满足spfilter条件的「拉比林斯迷宫」怪兽。
		local g=Duel.SelectMatchingCard(tp,c5380979.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区，并记录成功特殊召唤的数量。
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 调用「白银之城」联动处理：若满足对应场地等效果条件，则让玩家选择并破坏场上1张卡。
	aux.LabrynthDestroyOp(e,tp,res)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不是恶魔族怪兽不能从卡组·额外卡组特殊召唤。②：这个回合没有送去墓地的这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡在自己场上盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c5380979.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将上述自肃效果注册到当前玩家tp，使其直到下个回合结束为止持续生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的过滤函数：任何将要特殊召唤的怪兽，如果不是恶魔族且来自卡组或额外卡组，则不能特殊召唤。
function c5380979.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果离场事件的过滤器：判断离场的卡原本在主要怪兽区且是因效果离场。
function c5380979.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- ②效果的发动条件判定：本回合有怪兽因自己发动的通常陷阱卡的效果从场上离开，该离场怪兽不包含这张「拉比林斯迷宫欢迎」；且触发来源是通常陷阱卡；同时满足这张卡不是本回合被送去墓地（aux.exccon）的限制。
function c5380979.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5380979.cfilter,1,nil) and not eg:IsContains(e:GetHandler()) and rp==tp
		-- 追加判定：触发离场效果的那张卡必须是通常陷阱卡（re为陷阱类型且其原类型也是陷阱卡），并且这张「拉比林斯迷宫欢迎」不是在本回合被送去墓地。
		and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP and aux.exccon(e)
end
-- ②效果的发动时点判定与登记：确认这张卡可以被盖放，并登记操作信息。
function c5380979.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 向系统登记操作信息：将把墓地的这张卡移回场上（盖放），供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其盖放到自己的魔法与陷阱区域。
function c5380979.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡以里侧表示盖放在自己场上。
		Duel.SSet(tp,c)
	end
end
