--獄花の大燿聖ストリチア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡只要在中央的主要怪兽区域存在，原本攻击力变成3000。
-- ②：自己·对方的主要阶段才能发动。从自己的手卡·墓地把1只6星以下的「耀圣」怪兽特殊召唤。那之后，可以让场上的全部4星以上的怪兽的等级直到回合结束时下降3星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用复活限制，并注册两个效果：①原本攻击力变为3000；②发动条件为己方主要阶段的特殊召唤效果。
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡只要在中央的主要怪兽区域存在，原本攻击力变成3000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。从自己的手卡·墓地把1只6星以下的「耀圣」怪兽特殊召唤。那之后，可以让场上的全部4星以上的怪兽的等级直到回合结束时下降3星。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断该卡是否在中央主要怪兽区域（序列2），用于效果①的触发条件。
function s.atkcon(e)
	return e:GetHandler():GetSequence()==2
end
-- 判断是否处于己方主要阶段，用于效果②的发动条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于己方主要阶段，用于效果②的发动条件。
	return Duel.IsMainPhase()
end
-- 过滤满足条件的「耀圣」怪兽，包括等级不超过6星且可特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d8) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果②的发动条件，检查己方手牌或墓地是否存在满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位，用于效果②的发动条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方手牌或墓地是否存在满足条件的「耀圣」怪兽，用于效果②的发动条件。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果②的处理信息，表示将特殊召唤1只「耀圣」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤场上正面表示且等级不低于4的怪兽，用于判断是否可以下降等级。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- 处理效果②的发动，选择并特殊召唤1只「耀圣」怪兽，若成功则可选择是否让场上怪兽等级下降。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位，用于特殊召唤的条件判断。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方手牌或墓地选择1只满足条件的「耀圣」怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤到己方场上。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 刷新场上状态，确保效果正确处理。
			Duel.AdjustAll()
			-- 检查场上是否存在正面表示且等级不低于4的怪兽，用于判断是否可以下降等级。
			if Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 询问玩家是否选择让场上怪兽等级下降。
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否下降等级？"
				-- 中断当前效果处理，使后续效果视为不同时处理。
				Duel.BreakEffect()
				-- 获取场上所有正面表示且等级不低于4的怪兽。
				local lg=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
				-- 遍历所有符合条件的怪兽，为它们添加等级下降效果。
				for lc in aux.Next(lg) do
					-- 为场上怪兽添加等级下降3星的效果，持续到回合结束。
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_LEVEL)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					e1:SetValue(-3)
					lc:RegisterEffect(e1)
				end
			end
		end
	end
	-- 设置永续效果，使己方本回合不能从额外卡组特殊召唤非同调怪兽。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给己方玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 定义效果②的限制条件，禁止己方从额外卡组特殊召唤非同调怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
