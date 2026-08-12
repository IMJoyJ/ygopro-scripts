--ミッド・ピース・ゴーレム
-- 效果：
-- 自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「小块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c58843503.initial_effect(c)
	-- 自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「小块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58843503,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c58843503.spcon)
	e1:SetTarget(c58843503.sptg)
	e1:SetOperation(c58843503.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「大块石人」
function c58843503.cfilter(c)
	return c:IsFaceup() and c:IsCode(25247218)
end
-- 发动条件：检查自己场上是否存在表侧表示的「大块石人」
function c58843503.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件（表侧表示的「大块石人」）的卡
	return Duel.IsExistingMatchingCard(c58843503.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：卡组中可以特殊召唤的「小块石人」
function c58843503.filter(c,e,tp)
	return c:IsCode(22754505) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域空位以及卡组中是否存在可特殊召唤的「小块石人」，并设置特殊召唤的操作信息
function c58843503.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查阶段，则判断自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己卡组中是否存在至少1张可以特殊召唤的「小块石人」
		and Duel.IsExistingMatchingCard(c58843503.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果运行空间：从卡组选择1只「小块石人」特殊召唤，并将其效果无效化
function c58843503.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足过滤条件（「小块石人」）的卡
	local g=Duel.SelectMatchingCard(tp,c58843503.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
