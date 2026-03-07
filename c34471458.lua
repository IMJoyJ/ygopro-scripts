--フォーチュンレディ・ライティー
-- 效果：
-- ①：这张卡的攻击力·守备力变成这张卡的等级×200。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
-- ③：表侧表示的这张卡因效果从场上离开时才能发动。从卡组把1只「命运女郎」怪兽特殊召唤。
function c34471458.initial_effect(c)
	-- 效果原文内容：①：这张卡的攻击力·守备力变成这张卡的等级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c34471458.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34471458,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c34471458.lvcon)
	e3:SetOperation(c34471458.lvop)
	c:RegisterEffect(e3)
	-- 效果原文内容：③：表侧表示的这张卡因效果从场上离开时才能发动。从卡组把1只「命运女郎」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34471458,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c34471458.spcon)
	e4:SetTarget(c34471458.sptg)
	e4:SetOperation(c34471458.spop)
	c:RegisterEffect(e4)
end
-- 规则层面操作：设置卡片攻击力为等级乘以200
function c34471458.value(e,c)
	return c:GetLevel()*200
end
-- 规则层面操作：判断是否为自己的准备阶段
function c34471458.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面操作：将卡片等级提升1星（最多至12星）
function c34471458.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 规则层面操作：设置卡片等级增加1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断卡片因效果离开场上的条件
function c34471458.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 规则层面操作：过滤满足「命运女郎」卡组且可特殊召唤的怪兽
function c34471458.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足特殊召唤的条件（场地有空位且卡组有符合条件的怪兽）
function c34471458.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c34471458.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行特殊召唤操作
function c34471458.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c34471458.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
