--アロマリリス－ロザリーナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只调整以外的「芳香」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：为这张卡注册①手牌丢弃回血效果（e1），以及②召唤/特殊召唤成功时从卡组特召调整以外芳香怪兽的效果（e2/e3）。
function c24689197.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回复基本分"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只调整以外的「芳香」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- cost函数：检查这张卡是否可从手牌丢弃作为代价；若可以，实际发动时将手牌的这张卡丢弃并送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 丢弃代价：将这张卡从手牌送去墓地（原因设为代价+丢弃）。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 选取条件：目标为表侧表示、属于「芳香」字段、且攻击力大于0的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9) and c:GetAttack()>0
end
-- ①的取对象发动处理：选择自己场上1只表侧表示且攻击力>0的「芳香」怪兽为对象，计算回复值为该怪兽当前攻击力一半（向上取整），并写入回复效果的操作信息。
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 合法性检查：自己场上是否存在1只满足条件的「芳香」怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出提示，让玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行取对象：从自己场上选择1只符合条件的「芳香」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 取得所选择的1只对象怪兽，用于计算回复量。
	local tc=Duel.GetFirstTarget()
	local rec=math.ceil(tc:GetAttack()/2)
	-- 设置回复效果的操作信息：回复方为tp，回复量为rec（攻击力一半向上取整）。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- ①的效果处理：取出对象怪兽，重新计算攻击力一半（向上取整），若对象仍表侧表示且与该效果关联，则使tp回复相应基本分。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时取得对象怪兽（用于判定和计算回复）。
	local tc=Duel.GetFirstTarget()
	local rec=math.ceil(tc:GetAttack()/2)
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
	-- 使tp回复rec点基本分，并结束该条件分支。
	Duel.Recover(tp,rec,REASON_EFFECT) end
end
-- 特殊召唤的筛选条件：卡是「芳香」字段、不是调整、且可以被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件与目标设定：自己场上有空位且卡组存在可特殊召唤的调整以外「芳香」怪兽；并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，以保证特殊召唤有格子可用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只满足spfilter（调整以外「芳香」怪兽）的卡。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：确认有空位后，从卡组选择1只调整以外的「芳香」怪兽表侧表示特殊召唤，随后给自己附加直到回合结束不能特殊召唤植物族以外怪兽的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上无空余主要怪兽区，则整个特殊召唤效果不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的调整以外「芳香」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	-- 将选择的怪兽表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	-- 这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	-- 将自肃效果以场地效果形式注册给当前玩家tp，持续到结束阶段重置。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃条件：若即将特殊召唤的怪兽不是植物族，则禁止该特殊召唤；即只能特殊召唤植物族怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PLANT)
end
