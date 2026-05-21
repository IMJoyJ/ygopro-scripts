--接触するG
-- 效果：
-- ①：对方对怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡往对方场上守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡的控制者进行融合·同调·超量·连接召唤的场合，不是以这张卡为素材的融合·同调·超量·连接召唤不能进行。
function c87170768.initial_effect(c)
	-- ①：对方对怪兽的召唤·特殊召唤成功时才能发动。这张卡从手卡往对方场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87170768,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c87170768.condition)
	e1:SetTarget(c87170768.target)
	e1:SetOperation(c87170768.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡的控制者进行融合·同调·超量·连接召唤的场合，不是以这张卡为素材的融合·同调·超量·连接召唤不能进行。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_MUST_BE_FMATERIAL)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_MUST_BE_SMATERIAL)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_MUST_BE_XMATERIAL)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_MUST_BE_LMATERIAL)
	c:RegisterEffect(e6)
end
-- 检查怪兽的召唤·特殊召唤控制者是否为指定玩家
function c87170768.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 确认当前召唤·特殊召唤成功的怪兽中是否存在对方召唤·特殊召唤的怪兽
function c87170768.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c87170768.cfilter,1,nil,1-tp)
end
-- 验证发动条件是否满足，即对方场上有空位且这张卡可以特殊召唤到对方场上
function c87170768.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可供特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡在手卡存在，则将其往对方场上表侧守备表示特殊召唤
function c87170768.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡往对方场上表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
