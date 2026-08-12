--飆風の空牙団
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把1只4星以下的「空牙团」怪兽特殊召唤。对方场上有怪兽2只以上存在的场合，可以再从卡组把1只「空牙团」怪兽特殊召唤。这个回合，自己不是「空牙团」怪兽不能特殊召唤。
-- ②：自己为让「空牙团」怪兽的效果发动而把手卡丢弃的场合，可以作为那1张卡的代替而把墓地的这张卡除外。
local s,id,o=GetID()
-- 创建并注册两个效果：①主要怪兽区无怪兽时可发动特殊召唤效果；②墓地时可代替手卡丢弃发动空牙团效果
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把1只4星以下的「空牙团」怪兽特殊召唤。对方场上有怪兽2只以上存在的场合，可以再从卡组把1只「空牙团」怪兽特殊召唤。这个回合，自己不是「空牙团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己为让「空牙团」怪兽的效果发动而把手卡丢弃的场合，可以作为那1张卡的代替而把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
end
-- 判断自己场上是否没有怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上没有怪兽存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选满足条件的4星以下空牙团怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选满足条件的空牙团怪兽（无星数限制）
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理目标为从卡组特殊召唤怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的空牙团怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的特殊召唤操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的空牙团怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 判断对方场上是否有2只以上怪兽
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,2,nil)
			-- 判断自己场上是否有空格
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断卡组中是否存在满足条件的空牙团怪兽
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否再特殊召唤一次
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的空牙团怪兽
			local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置永续效果：本回合不能特殊召唤非空牙团怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该永续效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果目标为非空牙团怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x114)
end
