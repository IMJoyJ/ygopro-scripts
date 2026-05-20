--モノマネンド
-- 效果：
-- 「模仿黏土」在1回合只能发动1张。
-- ①：对方场上有怪兽存在的场合，以自己场上1只2星以下的表侧守备表示怪兽为对象才能发动。那1只同名怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c5972394.initial_effect(c)
	-- 「模仿黏土」在1回合只能发动1张。①：对方场上有怪兽存在的场合，以自己场上1只2星以下的表侧守备表示怪兽为对象才能发动。那1只同名怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,5972394+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c5972394.condition)
	e1:SetTarget(c5972394.target)
	e1:SetOperation(c5972394.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：对方场上是否存在怪兽
function c5972394.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤自己场上2星以下、表侧守备表示，且卡组中存在同名怪兽可特殊召唤的怪兽
function c5972394.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsPosition(POS_FACEUP_DEFENSE)
		-- 检查卡组中是否存在可以守备表示特殊召唤的同名怪兽
		and Duel.IsExistingMatchingCard(c5972394.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤卡组中同名且可以守备表示特殊召唤的怪兽
function c5972394.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动时的目标选择与合法性检查函数
function c5972394.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5972394.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在符合条件的可选择对象
		and Duel.IsExistingTarget(c5972394.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)  --"请选择表侧守备表示的怪兽"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c5972394.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理的执行函数
function c5972394.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与对象怪兽同名的怪兽
	local g=Duel.SelectMatchingCard(tp,c5972394.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	-- 将选择的怪兽以守备表示特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
