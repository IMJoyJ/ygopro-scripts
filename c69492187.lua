--アイス・ミラー
-- 效果：
-- ①：以自己场上1只3星以下的水属性怪兽为对象才能发动。那1只同名怪兽从卡组特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
function c69492187.initial_effect(c)
	-- ①：以自己场上1只3星以下的水属性怪兽为对象才能发动。那1只同名怪兽从卡组特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c69492187.target)
	e1:SetOperation(c69492187.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、等级3以下的水属性怪兽，且卡组中存在其同名怪兽
function c69492187.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
		-- 检查卡组中是否存在该怪兽的同名卡
		and Duel.IsExistingMatchingCard(c69492187.filter2,tp,LOCATION_DECK,0,1,nil,c:GetCode(),e,tp)
end
-- 过滤卡组中与目标怪兽同名且可以特殊召唤的怪兽
function c69492187.filter2(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择
function c69492187.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c69492187.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的对象怪兽
		and Duel.IsExistingTarget(c69492187.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只满足条件的对象怪兽并将其设为效果对象
	local g=Duel.SelectTarget(tp,c69492187.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（特殊召唤同名怪兽并施加额外卡组特召限制）
function c69492187.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与对象怪兽同名的怪兽
	local sg=Duel.SelectMatchingCard(tp,c69492187.filter2,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode(),e,tp)
	local sc=sg:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤，若特殊召唤成功则施加限制
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不能从额外卡组把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetCondition(c69492187.splimitcon)
		e1:SetTarget(c69492187.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1,true)
	end
end
-- 限制效果的适用条件：该怪兽在自己场上表侧表示存在（控制权未发生改变）
function c69492187.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 限制特殊召唤的范围为额外卡组
function c69492187.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
