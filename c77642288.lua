--剣闘獣セクトル
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡进行战斗的战斗阶段结束时，从卡组把「剑斗兽 追斗」以外的2只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c77642288.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡进行战斗的战斗阶段结束时，从卡组把「剑斗兽 追斗」以外的2只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77642288,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c77642288.spcon)
	e1:SetTarget(c77642288.sptg)
	e1:SetOperation(c77642288.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡是否由「剑斗兽」怪兽的效果特殊召唤，且在此阶段进行过战斗。
function c77642288.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否由「剑斗兽」怪兽的效果特殊召唤。
	return aux.gbspcon(e,tp,eg,ep,ev,re,r,rp)
		and e:GetHandler():GetBattledGroupCount()>0
end
-- 过滤卡组中除「剑斗兽 追斗」以外、可以特殊召唤的「剑斗兽」怪兽。
function c77642288.filter(c,e,tp)
	return not c:IsCode(77642288) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标处理：由于是必发效果，直接返回true，并设置特殊召唤2只怪兽的操作信息。
function c77642288.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只「剑斗兽 追斗」以外的「剑斗兽」怪兽在自己场上特殊召唤。
function c77642288.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的怪兽区域空位是否少于2个，若少于2个则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查卡组中是否存在至少2只满足条件的「剑斗兽」怪兽，若不足则不处理。
	if not Duel.IsExistingMatchingCard(c77642288.filter,tp,LOCATION_DECK,0,2,nil,e,tp) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择2只满足条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c77642288.filter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示逐步特殊召唤到场上。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=g:GetNext()
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
