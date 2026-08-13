--イリュージョン・スナッチ
-- 效果：
-- ①：自己对怪兽的上级召唤成功时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
function c35073065.initial_effect(c)
	-- ①：自己对怪兽的上级召唤成功时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的种族·属性·等级变成和上级召唤的那只怪兽相同。
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
-- 效果发动条件：自己场上有怪兽上级召唤成功（召唤成功的怪兽的控制者为发动者，且召唤类型为上级召唤）。
function c35073065.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动效果前合法检查：确认自己的主要怪兽区有空位，且手卡的这张卡能够被特殊召唤。
function c35073065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将诱发效果的上级召唤成功的那只怪兽设为本效果的对象，以确保后续处理时能获取该怪兽的状态。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本效果将特殊召唤手卡的这张卡，数量为1，供其他卡在连锁中判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡从手卡特殊召唤到己方场上；若召唤成功且上级召唤的那只怪兽仍与效果关联且表侧表示，则让这张卡的种族、属性、等级分别变成那只怪兽当前的种族、属性、等级。
function c35073065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	if not c:IsRelateToEffect(e) then return end
	-- 以特殊召唤步骤将这张卡以表侧表示特殊召唤到自己场上（成功后继续赋予变化效果）。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if ec:IsRelateToEffect(e) and ec:IsFaceup() then
			-- 这个效果特殊召唤的这张卡的种族变成和上级召唤的那只怪兽相同。
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
			-- 这个效果特殊召唤的这张卡的属性变成和上级召唤的那只怪兽相同。
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
			-- 这个效果特殊召唤的这张卡的等级变成和上级召唤的那只怪兽相同。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_LEVEL)
			e3:SetValue(ec:GetLevel())
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e3)
		end
	end
	-- 完成特殊召唤处理，结束特殊召唤步骤，使本次连锁中的特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
