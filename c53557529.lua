--飆風の空牙団
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合才能发动。从卡组把1只4星以下的「空牙团」怪兽特殊召唤。对方场上有怪兽2只以上存在的场合，可以再从卡组把1只「空牙团」怪兽特殊召唤。这个回合，自己不是「空牙团」怪兽不能特殊召唤。
-- ②：自己为让「空牙团」怪兽的效果发动而把手卡丢弃的场合，可以作为那1张卡的代替而把墓地的这张卡除外。
local s,id,o=GetID()
-- 初始化函数：注册卡片①效果的发动（从卡组特殊召唤「空牙团」怪兽）与②效果的墓地代替丢弃效果。
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
-- ①效果的发动条件函数：判定自己场上没有怪兽存在时才允许发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的主要怪兽区是否存在怪兽：若不存在怪兽，则条件成立，允许发动。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
end
-- 第一个特殊召唤的筛选条件：卡组中的「空牙团」怪兽、4星以下、且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第二个特殊召唤的筛选条件：卡组中的「空牙团」怪兽、且能被当前效果特殊召唤（无等级限制）。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时的目标合法性判断函数：确认自己怪兽区有空位，且卡组存在可特殊召唤的4星以下「空牙团」怪兽；满足则返回真，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的主要怪兽区必须有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在至少1只满足第一个特殊召唤条件的「空牙团」怪兽，才允许发动。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行特殊召唤，预计从自己的卡组特殊召唤1只怪兽（对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：先从卡组选1只4星以下的「空牙团」怪兽特殊召唤；若对方场上有2只以上怪兽且自己怪兽区有空位且卡组还有可特殊召唤的「空牙团」怪兽，则询问玩家是否再特殊召唤1只；最后给自己附加本回合不能特殊召唤「空牙团」以外怪兽的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己的主要怪兽区仍存在空位，才执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送选择提示消息：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1张满足第一个过滤条件的「空牙团」怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 若成功选到卡且该怪兽特殊召唤成功，才进入后续是否追加特殊召唤的判断。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 检查对方场上是否存在至少2只怪兽（对方怪兽2只以上存在的场合成立）。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,2,nil)
			-- 并且自己怪兽区仍有空位，才能追加特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且卡组中仍存在至少1只可特殊召唤的「空牙团」怪兽（满足第二个过滤条件），才能追加召唤。
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
			-- 询问玩家是否再特殊召唤1只「空牙团」怪兽；选择“是”才执行追加特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再特殊召唤？"
			-- 中断当前效果处理，使追加的特殊召唤被视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 向玩家发送选择提示消息：请选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从卡组选择1张满足第二个过滤条件的「空牙团」怪兽作为追加特殊召唤对象。
			local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			-- 将追加选择的「空牙团」怪兽以表侧表示特殊召唤到自己的怪兽区。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是「空牙团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述特殊召唤限制效果注册给当前回合玩家，效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：被特殊召唤的怪兽不是「空牙团」字段时，该特殊召唤被禁止。
function s.splimit(e,c)
	return not c:IsSetCard(0x114)
end
