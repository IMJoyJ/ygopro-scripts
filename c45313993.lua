--レッド・ウルフ
-- 效果：
-- ①：自己把「共鸣者」怪兽召唤时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成一半。
function c45313993.initial_effect(c)
	-- 创建一个字段诱发效果，满足条件时可以从手卡特殊召唤此卡
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
-- 效果发动条件：自己将「共鸣者」怪兽召唤时
function c45313993.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSetCard(0x57)
end
-- 效果处理时的确认条件：玩家场上存在空怪兽区域且此卡可被特殊召唤
function c45313993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认玩家场上是否存在空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置此效果处理时的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时执行的操作：将此卡特殊召唤并将其攻击力变为一半
function c45313993.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤步骤，将此卡以正面表示特殊召唤到场上
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetAttack()
		-- 将此卡的攻击力变为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
