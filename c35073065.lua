--イリュージョン・スナッチ
-- 效果：
-- ①：自己对怪兽的上级召唤成功时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
function c35073065.initial_effect(c)
	-- 效果原文：①：自己对怪兽的上级召唤成功时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35073065,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c35073065.spcon)
	e1:SetTarget(c35073065.sptg)
	e1:SetOperation(c35073065.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
end
-- 效果作用：判断是否为自己的上级召唤成功
function c35073065.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果作用：检测是否满足特殊召唤条件
function c35073065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有足够空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果作用：将上级召唤的怪兽设为连锁对象
	Duel.SetTargetCard(eg)
	-- 效果作用：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果作用：处理特殊召唤及后续种族、属性、等级变更
function c35073065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	if not c:IsRelateToEffect(e) then return end
	-- 效果作用：执行特殊召唤步骤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if ec:IsRelateToEffect(e) and ec:IsFaceup() then
			-- 效果原文：这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			if ec:IsHasEffect(EFFECT_ADD_RACE) and not ec:IsHasEffect(EFFECT_CHANGE_RACE) then
				e1:SetValue(ec:GetOriginalRace())
			else
				e1:SetValue(ec:GetRace())
			end
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			-- 效果原文：这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			if ec:IsHasEffect(EFFECT_ADD_ATTRIBUTE) and not ec:IsHasEffect(EFFECT_CHANGE_ATTRIBUTE) then
				e2:SetValue(ec:GetOriginalAttribute())
			else
				e2:SetValue(ec:GetAttribute())
			end
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
			-- 效果原文：这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(ec:GetLevel())
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e3)
		end
	end
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
