--緋ノ異解△ナラカ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方把怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把4张卡里侧除外。
-- ③：对方主要阶段才能发动。自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。这个回合，自己不能把「异解△」卡以外的卡的效果发动。
local s,id,o=GetID()
-- 注册卡片初始效果：①对方特殊召唤怪兽时从手卡特召；②召唤·特殊召唤成功时卡组顶端里侧除外4张卡；③对方主要阶段特召除外状态里侧高星异解怪兽并施加发动限制
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：对方把怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把4张卡里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：对方主要阶段才能发动。自己的除外状态（里侧）的1只5星以上的「异解△」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 过滤对方特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- ①效果的发动条件：存在对方特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果的目标：检查主要怪兽区空格并确认自身能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：从手卡特殊召唤这张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的目标：获取卡组顶端4张卡并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自身卡组顶端的4张卡
	local dg=Duel.GetDecktopGroup(tp,4)
	if chk==0 then return true end
	-- 设置除外卡组顶端4张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果的处理：将卡组顶端的4张卡里侧除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身卡组顶端的4张卡
	local dg=Duel.GetDecktopGroup(tp,4)
	if dg and dg:GetCount()>0 then
		-- 禁用下一次操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组顶端的卡以里侧表示除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被里侧除外的卡片以添加客户端提示
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「绯之异解△奈落迦」被里侧除外"
				end
			end
		end
	end
end
-- ③效果的发动条件：在对方回合的主要阶段
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 过滤除外状态里侧表示、5星以上且可特殊召唤的「异解△」怪兽
function s.spfilter(c,e,tp)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsLevelAbove(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标：检查主要怪兽区空格与除外区目标怪兽并设置特殊召唤操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足条件的里侧表示「异解△」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤除外区1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理：特殊召唤除外状态里侧表示的1只5星以上「异解△」怪兽，并在本回合限制发动非「异解△」卡的效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从除外区选择1只满足条件的里侧表示「异解△」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把「异解△」卡以外的卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合不能发动非「异解△」卡效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非「异解△」卡的发动限制
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x1ed)
end
