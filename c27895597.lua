--フォーチュンレディ・コーリング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「命运女郎」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只「命运女郎」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
function c27895597.initial_effect(c)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。①：自己场上有「命运女郎」怪兽存在的场合才能发动。同名卡不在自己场上存在的1只「命运女郎」怪兽从卡组特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27895597+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c27895597.spcon)
	e1:SetTarget(c27895597.sptg)
	e1:SetOperation(c27895597.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片为表侧表示且字段为「命运女郎」（用于检查自己场上有表侧命运女郎怪兽存在作为发动条件）。
function c27895597.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x31)
end
-- 发动条件判定：自己场上存在至少1只表侧表示的「命运女郎」怪兽时，该卡才能发动。
function c27895597.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足cfilter的卡，即至少1只表侧「命运女郎」怪兽，存在则发动条件成立。
	return Duel.IsExistingMatchingCard(c27895597.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特召对象的筛选条件：候选卡必须是「命运女郎」怪兽，可被当前效果特殊召唤（检查召唤条件/苏生限制），并且自己场上没有表侧表示的同名卡（‘同名卡不在自己场上存在’）。
function c27895597.tfilter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 排除自己场上存在与候选卡同卡名且表侧表示的卡；若存在这样的卡，则该候选卡不可被选择。
		and not Duel.IsExistingMatchingCard(c27895597.bfilter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
-- 用于比较候选卡tc与场上卡c是否为同一卡号，且场上卡c处于表侧表示，以此判断‘同名卡不在自己场上存在’。
function c27895597.bfilter(c,tc)
	return tc:IsCode(c:GetCode()) and c:IsFaceup()
end
-- 发动前检查：自己主要怪兽区有空位，并且卡组中存在至少1张满足tfilter条件的「命运女郎」怪兽，满足才可发动效果。
function c27895597.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，确认自己主要怪兽区是否有可用空格作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认卡组中存在至少1张符合条件的「命运女郎」怪兽（满足字段、可特召、无同名表侧在场）。
		and Duel.IsExistingMatchingCard(c27895597.tfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次处理将进行1张卡组中「命运女郎」怪兽的特殊召唤；因对象在处理时选择，targets传nil，位置为卡组，操作者为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若自己主要怪兽区有空位，则从卡组选1只符合条件的「命运女郎」怪兽特殊召唤；之后给自己附加直到回合结束‘不能从额外卡组特殊召唤非同调怪兽’的自肃。
function c27895597.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查主要怪兽区是否有可用空格，避免处理时格子被占满导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1张满足tfilter条件的「命运女郎」怪兽（处理时选择，不取对象）。
		local g=Duel.SelectMatchingCard(tp,c27895597.tfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「命运女郎」怪兽以表侧攻击表示特殊召唤到自己场上（按规则检查特殊召唤条件和苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 对应效果原文：‘这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。’
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c27895597.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到发动者tp身上，使该玩家在回合结束前不能从额外卡组特召非同调怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃条件：若怪兽位于额外卡组且不是同调怪兽，则禁止其特殊召唤；即只允许从额外卡组特殊召唤同调怪兽。
function c27895597.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
