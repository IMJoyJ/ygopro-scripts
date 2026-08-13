--フォーチュンレディ・ライティー
-- 效果：
-- ①：这张卡的攻击力·守备力变成这张卡的等级×200。
-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
-- ③：表侧表示的这张卡因效果从场上离开时才能发动。从卡组把1只「命运女郎」怪兽特殊召唤。
function c34471458.initial_effect(c)
	-- ①：这张卡的攻击力·守备力变成这张卡的等级×200。
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
	-- ②：自己准备阶段发动。这张卡的等级上升1星（最多到12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34471458,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c34471458.lvcon)
	e3:SetOperation(c34471458.lvop)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡因效果从场上离开时才能发动。从卡组把1只「命运女郎」怪兽特殊召唤。
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
-- 返回这张卡当前等级乘以200，作为①效果中攻击力/守备力的数值。
function c34471458.value(e,c)
	return c:GetLevel()*200
end
-- lvcon条件：当前回合玩家是这张卡的控制者时，条件成立（用于己方准备阶段）。
function c34471458.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果发动者tp，确保只在己方准备阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- lvop操作：若此卡仍表侧、与效果关联且等级未超过12，则给它注册一个等级+1的效果。
function c34471458.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星（最多到12星）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- spcon条件：这张卡因效果离开场上，且离场前是表侧表示。
function c34471458.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- spfilter筛选：卡名属于「命运女郎」字段且能够被特殊召唤。
function c34471458.spfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg目标：发动时检查是否有空位且卡组存在符合条件的「命运女郎」怪兽，满足则发动并设置特殊召唤操作信息。
function c34471458.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只满足spfilter条件的「命运女郎」怪兽。
		and Duel.IsExistingMatchingCard(c34471458.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 把本次连锁处理信息设为：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- spop操作：处理时若仍有空位，则选择并特殊召唤1只「命运女郎」怪兽。
function c34471458.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若特殊召唤处理时已经没有可用怪兽区空格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足spfilter条件的「命运女郎」怪兽。
	local g=Duel.SelectMatchingCard(tp,c34471458.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
