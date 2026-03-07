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
	-- 效果原文内容：①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合才能把这个效果发动。从卡组把1只「龙星」怪兽特殊召唤。
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
	-- 效果原文内容：②：只要这张卡在魔法与陷阱区域存在，自己不能把同调怪兽以外的怪兽从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c30398342.sumlimit)
	c:RegisterEffect(e3)
end
-- 规则层面作用：判断被破坏的怪兽是否为己方场上怪兽且由战斗或效果破坏
function c30398342.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 规则层面作用：判断是否有己方场上被战斗或效果破坏的怪兽
function c30398342.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30398342.cfilter,1,nil,tp)
end
-- 规则层面作用：筛选满足条件的「龙星」怪兽（可特殊召唤）
function c30398342.filter(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件（场上有空位且卡组有符合条件的怪兽）
function c30398342.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断卡组中是否存在满足条件的「龙星」怪兽
		and Duel.IsExistingMatchingCard(c30398342.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行特殊召唤操作，选择并特殊召唤符合条件的怪兽
function c30398342.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断己方场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的「龙星」怪兽
	local g=Duel.SelectMatchingCard(tp,c30398342.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面作用：限制己方不能从额外卡组特殊召唤非同调怪兽
function c30398342.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
