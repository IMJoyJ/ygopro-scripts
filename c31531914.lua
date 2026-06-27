--破械式鬼シュマ
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「31531914」以外的1只4星以下的「破械」怪兽特殊召唤。那之后，选自己场上的1张卡破坏。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗或者「31531914」以外的效果破坏的场合才能发动。从手卡·卡组把「31531914」以外的1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级4以下且非同名的「破械」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①特殊召唤条件检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否存在怪兽位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组是否存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 声明特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 获取自己场上的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 声明破坏自己场上卡片的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果①的实际操作：从卡组特殊召唤怪兽，之后破坏我方场上的一张卡，并添加种族特召限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余怪兽位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 特殊召唤选中的怪兽并判断是否特殊召唤成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 切分效果时点
			Duel.BreakEffect()
			-- 提示选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 从我方场上选择1张要破坏的卡
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 高亮显示被选中的我方卡片
				Duel.HintSelection(sg)
				-- 将选中的卡片破坏
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
	-- 限制本回合后续特召的种族
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的过滤器：非恶魔族怪兽无法进行特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 效果②触发条件：在场上被战斗或者非同名的效果破坏
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤非同名且符合特召条件的「破械」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②特殊召唤条件检查与声明
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否存在怪兽位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 声明从手牌或卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的实际操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认我方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
