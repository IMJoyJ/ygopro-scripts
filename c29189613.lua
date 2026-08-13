--アロマガーデニング
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对「芳香」怪兽的召唤·特殊召唤成功的场合才能发动。自己回复1000基本分。
-- ②：自己基本分比对方少的场合，对方怪兽的攻击宣言时才能发动。从卡组把1只「芳香」怪兽特殊召唤。
function c29189613.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己对「芳香」怪兽的召唤·特殊召唤成功的场合才能发动。自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29189613,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,29189613)
	e2:SetCondition(c29189613.reccon)
	e2:SetTarget(c29189613.rectg)
	e2:SetOperation(c29189613.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：自己基本分比对方少的场合，对方怪兽的攻击宣言时才能发动。从卡组把1只「芳香」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29189613,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCountLimit(1,29189614)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c29189613.spcon)
	e4:SetTarget(c29189613.sptg)
	e4:SetOperation(c29189613.spop)
	c:RegisterEffect(e4)
end
-- 筛选召唤·特殊召唤成功的怪兽：必须是表侧表示、由效果发动者召唤/特殊召唤、且属于「芳香」系列的怪兽。
function c29189613.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0xc9)
end
-- ①效果的发动条件：本次召唤/特殊召唤成功的怪兽中存在由我方召唤/特殊召唤的表侧表示「芳香」怪兽。
function c29189613.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29189613.cfilter,1,nil,tp)
end
-- ①效果发动时的目标处理：无对象要求即满足发动条件，将回复对象玩家设为自己，回复量设为1000，并登记回复效果的操作信息。
function c29189613.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为自己（作为回复基本分的对象）。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的参数值为1000，即回复基本分的数值。
	Duel.SetTargetParam(1000)
	-- 登记回复效果的操作信息：分类为恢复（CATEGORY_RECOVER），目标为自己，回复量为1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- ①效果处理时：取得之前记录的目标玩家与回复数值，并让该玩家回复相应基本分。
function c29189613.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家（p）和参数值（d，即回复量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- ②效果的发动条件：攻击怪兽为对方怪兽（攻击者控制者不是自己），且自己的基本分少于对方。
function c29189613.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击者是对方控制的怪兽，且自己LP低于对方LP，两者同时满足才可发动。
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- 筛选卡组中满足条件的「芳香」怪兽：卡名属于「芳香」系列，且可以被当前效果特殊召唤。
function c29189613.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件与目标设定：检测自己怪兽区有空位且卡组存在可特殊召唤的「芳香」怪兽，并登记特殊召唤的操作信息。
function c29189613.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）先确认自己主要怪兽区是否有空闲区域可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在1张以上满足特殊召唤条件的「芳香」怪兽，才允许发动。
		and Duel.IsExistingMatchingCard(c29189613.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记特殊召唤效果的操作信息：分类为特殊召唤（CATEGORY_SPECIAL_SUMMON），从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理时：确认此卡仍与效果关联且场上仍有空位，然后从卡组选择1只「芳香」怪兽以表侧表示特殊召唤。
function c29189613.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前校验：此卡仍与效果关联（未离场或效果未被无效），且自己主要怪兽区仍有空位，否则不进行处理。
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己弹出“请选择要特殊召唤的卡”的选择提示（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足条件的「芳香」怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c29189613.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示（POS_FACEUP）特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
