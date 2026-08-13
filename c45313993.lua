--レッド・ウルフ
-- 效果：
-- ①：自己把「共鸣者」怪兽召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成一半。
function c45313993.initial_effect(c)
	-- ①：自己把「共鸣者」怪兽召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45313993,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45313993.spcon)
	e1:SetTarget(c45313993.sptg)
	e1:SetOperation(c45313993.spop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：本次通常召唤成功的怪兽由己方控制，且该怪兽的卡名属于「共鸣者」字段（0x57）。
function c45313993.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSetCard(0x57)
end
-- 效果发动时的合法性检查与操作信息设置：确认主怪兽区有空位且此卡能被特殊召唤，随后将本效果的操作信息登记为特殊召唤此卡。
function c45313993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在检查发动合法性（chk==0）时执行：确认自己的主要怪兽区存在可用空格，且此卡能够被特殊召唤，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本效果将把此卡（e:GetHandler()）特殊召唤，数量为1，供连锁处理中其他效果（如星尘龙等）进行判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先确认此卡仍与当前效果保持关联；若成功将其以表侧表示特殊召唤，则把其当前攻击力变为一半（向上取整）并设置该攻击力变化会在标准离场/移动时机重置；最后完成整个特殊召唤处理。
function c45313993.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将手牌中的此卡以表侧攻击表示特殊召唤（不检查召唤条件且不检查苏生限制）；若特殊召唤成功则进入分支处理攻击力减半。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetAttack()
		-- 这个效果特殊召唤的这张卡的攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的收尾处理，结束与 Duel.SpecialSummonStep 配合使用的整个特殊召唤流程。
	Duel.SpecialSummonComplete()
end
