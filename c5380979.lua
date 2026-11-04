--ウェルカム・ラビュリンス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「拉比林斯迷宫」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是恶魔族怪兽不能从卡组·额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。这张卡在自己场上盖放。这个效果在这张卡送去墓地的回合不能发动。
function c5380979.initial_effect(c)
	-- ①：从卡组把1只「拉比林斯迷宫」怪兽特殊召唤。
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
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,5380980)
	e2:SetCondition(c5380979.setcon)
	e2:SetTarget(c5380979.settg)
	e2:SetOperation(c5380979.setop)
	c:RegisterEffect(e2)
end
-- 过滤「拉比林斯迷宫」怪兽
function c5380979.spfilter(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 确认怪兽区空位及卡组是否存在「拉比林斯迷宫」怪兽
function c5380979.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在「拉比林斯迷宫」怪兽
		and Duel.IsExistingMatchingCard(c5380979.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组特殊召唤「拉比林斯迷宫」怪兽并施加特招自肃
function c5380979.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=0
	-- 检查怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只「拉比林斯迷宫」怪兽
		local g=Duel.SelectMatchingCard(tp,c5380979.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将怪兽表侧表示特殊召唤
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 触发白银之城联动破坏处理
	aux.LabrynthDestroyOp(e,tp,res)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不是恶魔族怪兽不能从卡组·额外卡组特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c5380979.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 对玩家注册不能特殊召唤非恶魔族怪兽的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能从卡组·额外卡组特殊召唤非恶魔族怪兽
function c5380979.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤因效果从怪兽区离开的怪兽
function c5380979.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 确认是否为自己的通常陷阱效果让怪兽离场且非本回合送墓
function c5380979.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5380979.cfilter,1,nil) and not eg:IsContains(e:GetHandler()) and rp==tp
		-- 确认由通常陷阱发动且本卡非本回合送去墓地
		and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP and aux.exccon(e)
end
-- 确认自身是否可在场上盖放
function c5380979.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：从墓地离开自身
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放自身的效果处理
function c5380979.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 在场上盖放自身
		Duel.SSet(tp,c)
	end
end
