--ゼンマイシャーク
-- 效果：
-- ①：自己场上有「发条」怪兽召唤·特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●这张卡的等级直到回合结束时上升1星。
-- ●这张卡的等级直到回合结束时下降1星。
function c25484449.initial_effect(c)
	-- 效果原文：①：自己场上有「发条」怪兽召唤·特殊召唤时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25484449,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c25484449.spcon)
	e1:SetTarget(c25484449.sptg)
	e1:SetOperation(c25484449.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文：②：1回合1次，可以从以下效果选择1个发动。●这张卡的等级直到回合结束时上升1星。●这张卡的等级直到回合结束时下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25484449,1))  --"等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c25484449.lvtg)
	e3:SetOperation(c25484449.lvop)
	c:RegisterEffect(e3)
end
-- 规则层面：判断目标怪兽是否为「发条」族且在场上正面表示存在
function c25484449.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x58)
end
-- 规则层面：判断是否有满足条件的「发条」怪兽被召唤或特殊召唤成功
function c25484449.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25484449.cfilter,1,nil,tp)
end
-- 规则层面：判断是否满足特殊召唤条件（场地有空位且自身可特殊召唤）
function c25484449.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c25484449.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面：选择等级上升或下降效果
function c25484449.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：提示玩家选择效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 规则层面：选择等级上升或下降选项
	local op=Duel.SelectOption(tp,aux.Stringid(25484449,2),aux.Stringid(25484449,3))  --"等级上升/等级下降"
	e:SetLabel(op)
end
-- 规则层面：根据选择结果设置等级变化效果
function c25484449.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 规则层面：设置等级变化效果，使等级上升或下降
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
