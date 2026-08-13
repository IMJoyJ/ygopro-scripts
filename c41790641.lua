--エレキングダム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能把位于这张卡以及自己场上的「电气」怪兽的正对面的对方怪兽自身的召唤·特殊召唤成功时的效果发动。
-- ②：以自己场上1只「电气」怪兽为对象才能发动。和那只怪兽卡名不同的1只「电气」怪兽从卡组特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的攻击力数值的基本分。这个效果的发动后，直到回合结束时自己不是雷族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册「电气王国」的发动效果（允许作为永续魔法发动）、①的对方效果发动限制效果，以及②的起动特殊召唤效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方不能把位于这张卡以及自己场上的「电气」怪兽的正对面的对方怪兽自身的召唤·特殊召唤成功时的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.actlim)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「电气」怪兽为对象才能发动。和那只怪兽卡名不同的1只「电气」怪兽从卡组特殊召唤。那之后，自己失去这个效果特殊召唤的怪兽的攻击力数值的基本分。这个效果的发动后，直到回合结束时自己不是雷族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断c是否为表侧表示且属于「电气」，且位于我方怪兽区并受我控制，用于①效果中判断对方怪兽是否位于「电气」怪兽的正对面。
function s.lfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xe) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判定对方发动的效果是否为召唤·特殊召唤成功时发动的效果，只有这类效果才会被①效果限制，否则不适用。
function s.actlim(e,re,tp)
	if not re:IsActivated() or re:GetCode()~=EVENT_SUMMON_SUCCESS
		and re:GetCode()~=EVENT_SPSUMMON_SUCCESS then return end
	local rc=re:GetHandler()
	local rg=rc:GetColumnGroup()
	local p=e:GetHandlerPlayer()
	return rc:IsControler(1-p) and rg:IsContains(e:GetHandler()) or rg:IsExists(s.lfilter,1,nil,p)
end
-- 取对象候选过滤：选择自己场上表侧表示的「电气」怪兽，且卡组中存在与它卡名不同的可以特殊召唤的「电气」怪兽，以保证②效果有可特召目标。
function s.cfilter(c,e,tp)
	-- 返回过滤条件：c是自己场上表侧表示的「电气」怪兽，并且卡组中存在满足s.filter的可特殊召唤的「电气」怪兽。
	return c:IsFaceup() and c:IsSetCard(0xe) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数：从卡组选择属于「电气」、可以被本次效果特殊召唤、且与已选对象怪兽卡名不同的怪兽。
function s.filter(c,e,tp,...)
	return c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(...)
end
-- 连锁处理中确认对象时，检查对象位于我方怪兽区、由我方控制、表侧表示且属于「电气」系怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup()
		and chkc:IsSetCard(0xe) end
	-- 发动条件检查：自己主要怪兽区存在可用空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己场上存在满足s.cfilter的「电气」怪兽可作为效果对象。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作玩家发出“选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从自己场上选择1只表侧表示的「电气」怪兽作为②效果的对象。
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行从卡组特殊召唤1只怪兽，供其他卡响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 自肃过滤函数：判断怪兽不是雷族，用于设置不能特殊召唤雷族以外怪兽的限制。
function s.splim(e,c)
	return c:GetRace()~=RACE_THUNDER
end
-- ②效果处理：若对象仍合法且怪兽区有空位，则从卡组选1只与对象卡名不同的「电气」怪兽特殊召唤；若特召成功且其攻击力大于0，则失去该攻击力数值的基本分；最后给己方附加回合结束前不能特殊召唤雷族以外怪兽的自肃。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象仍与效果关联、表侧表示且自己场上还有可用的怪兽区空格，满足才继续特殊召唤处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家发出选择要特殊召唤的卡片的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足s.filter的「电气」怪兽（与对象卡名不同、可特殊召唤）并取回。
		local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode()):GetFirst()
		-- 如果选到了怪兽且特殊召唤成功，并且该怪兽表侧表示且攻击力大于0，则执行后续扣LP处理。
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and aux.nzatk(sc) then
			-- 中断当前效果处理，使后续的LP损失作为另一时点处理，避免与特殊召唤在同一时点并行错过时点。
			Duel.BreakEffect()
			-- 获取当前基本分，为扣LP做准备。
			local lp=Duel.GetLP(tp)
			-- 将己方基本分减去这张特殊召唤怪兽的攻击力数值，即失去对应基本分。
			Duel.SetLP(tp,lp-sc:GetAttack())
		end
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是雷族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤雷族以外怪兽”的自肃效果注册到当前玩家tp，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
