--リバース・オブ・ネオス
-- 效果：
-- 自己场上表侧表示存在的名字带有「新宇」的融合怪兽被破坏时才能发动。从自己卡组把1只「元素英雄 新宇侠」攻击表示特殊召唤。这个效果特殊召唤的「元素英雄 新宇侠」的攻击力只要在场上表侧表示存在上升1000，这个回合的结束阶段时破坏。
function c18302224.initial_effect(c)
	-- 向卡片c注册代码列表，记录效果文本中提到的「元素英雄 新宇侠」（卡号89943723），便于系统识别和处理该卡的关联信息。
	aux.AddCodeList(c,89943723)
	-- 向卡片c注册系列怪兽列表（字段0x3008），用于在效果中正确识别名字带有该系列的怪兽。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 自己场上表侧表示存在的名字带有「新宇」的融合怪兽被破坏时才能发动。从自己卡组把1只「元素英雄 新宇侠」攻击表示特殊召唤。这个效果特殊召唤的「元素英雄 新宇侠」的攻击力只要在场上表侧表示存在上升1000，这个回合的结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c18302224.condition)
	e1:SetTarget(c18302224.target)
	e1:SetOperation(c18302224.activate)
	c:RegisterEffect(e1)
end
-- 定义被破坏怪兽的筛选条件：该怪兽被破坏前在我方主要怪兽区表侧表示存在，且名字带有「新宇」、是融合怪兽。
function c18302224.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x9) and c:IsType(TYPE_FUSION)
end
-- 发动条件判定：本次被破坏的怪兽集合中是否存在至少1只满足上述条件（我方表侧「新宇」融合怪兽）。
function c18302224.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18302224.cfilter,1,nil,tp)
end
-- 目标筛选：从卡组中选择卡号为89943723（元素英雄 新宇侠）且能够被我方以表侧攻击表示特殊召唤的怪兽。
function c18302224.filter(c,e,tp)
	return c:IsCode(89943723) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的合法性检查：我方主要怪兽区有空位，且卡组中存在符合条件的目标怪兽。
function c18302224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否存在可用的主要怪兽区空格，确保能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「元素英雄 新宇侠」，作为发动前提之一。
		and Duel.IsExistingMatchingCard(c18302224.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理的操作信息为“从卡组特殊召唤1只怪兽”，使相关时点和卡片的联动能够正确检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若主要怪兽区仍有空位，则从卡组选择1只「元素英雄 新宇侠」以表侧攻击表示特殊召唤，并为其赋予攻击力上升和结束阶段破坏的效果。
function c18302224.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若无空位则直接终止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中筛选并选择1张符合条件的「元素英雄 新宇侠」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c18302224.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的「元素英雄 新宇侠」以表侧攻击表示进行特殊召唤（特殊召唤步骤），若成功则继续附加后续效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 这个效果特殊召唤的「元素英雄 新宇侠」的攻击力只要在场上表侧表示存在上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合的结束阶段时破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetOperation(c18302224.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		tc:RegisterEffect(e2,true)
	end
	-- 结束特殊召唤步骤，正式完成特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 定义结束阶段破坏的处理函数：将效果所属卡（被特殊召唤的「元素英雄 新宇侠」）破坏。
function c18302224.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡（被特殊召唤的「元素英雄 新宇侠」）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
