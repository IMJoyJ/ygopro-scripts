--竜星の具象化
-- 效果：
-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合才能把这个效果发动。从卡组把1只「龙星」怪兽特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，自己不能把同调怪兽以外的怪兽从额外卡组特殊召唤。
function c30398342.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合才能把这个效果发动。从卡组把1只「龙星」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30398342,0))  --"发动并使用①效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c30398342.spcon)
	e2:SetTarget(c30398342.sptg)
	e2:SetOperation(c30398342.spop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己不能把同调怪兽以外的怪兽从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c30398342.sumlimit)
	c:RegisterEffect(e3)
end
-- 判断被破坏的怪兽是否满足“因战斗或效果破坏，且破坏前在自己场上”的条件，即是否为“自己场上的怪兽被战斗·效果破坏”的怪兽。
function c30398342.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 检查本次破坏事件中是否存在至少1只满足cfilter条件的怪兽，从而判定①效果的发动条件是否成立。
function c30398342.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30398342.cfilter,1,nil,tp)
end
-- 筛选符合条件的「龙星」怪兽，要求卡名属于「龙星」字段，并且能够被当前效果特殊召唤。
function c30398342.filter(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点检查：自己场上主要怪兽区有空位，且卡组中存在可特殊召唤的「龙星」怪兽时，才允许发动。
function c30398342.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格，确保可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足条件的「龙星」怪兽；条件判定结束后返回true，允许发动。
		and Duel.IsExistingMatchingCard(c30398342.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次操作信息：从卡组特殊召唤1只怪兽（具体对象在处理时选择），用于其他卡片对该效果的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，若自己主要怪兽区仍有空位，则从卡组选择1只「龙星」怪兽，以表侧表示特殊召唤到自己场上。
function c30398342.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，若没有则特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动者tp发送卡片选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者tp从自己卡组中选择1只满足filter条件的「龙星」怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c30398342.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「龙星」怪兽以表侧表示特殊召唤到发动者tp的场上，完成①效果的特殊召唤处理。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的禁止特殊召唤判定：若怪兽c来自额外卡组且不是同调怪兽，则禁止该特殊召唤；即从额外卡组仅允许特殊召唤同调怪兽。
function c30398342.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
