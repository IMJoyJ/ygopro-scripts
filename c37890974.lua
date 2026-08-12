--空牙団の修練
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的「空牙团」怪兽被战斗或者对方的效果破坏的场合，以那1只怪兽为对象才能发动。从卡组把持有比那只怪兽的原本等级低的等级的1只「空牙团」怪兽特殊召唤。
function c37890974.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「空牙团」怪兽被战斗或者对方的效果破坏的场合，以那1只怪兽为对象才能发动。从卡组把持有比那只怪兽的原本等级低的等级的1只「空牙团」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37890974,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,37890974)
	e2:SetTarget(c37890974.sptg)
	e2:SetOperation(c37890974.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的被破坏怪兽，确保其为「空牙团」怪兽且在破坏时处于场上，且其等级大于0且卡组存在满足条件的「空牙团」怪兽。
function c37890974.spfilter1(c,e,tp,rp)
	local lv=c:GetLevel()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousSetCard(0x114) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在等级低于目标怪兽的「空牙团」怪兽，用于确认效果是否可以发动。
		and lv>0 and Duel.IsExistingMatchingCard(c37890974.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 过滤满足条件的「空牙团」怪兽，确保其等级低于目标怪兽且可以被特殊召唤。
function c37890974.spfilter2(c,e,tp,lv)
	return c:GetLevel()<lv and c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件，即场上存在满足条件的被破坏怪兽。
function c37890974.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c37890974.spfilter1(chkc,e,tp,rp) end
	-- 检查玩家场上是否有足够的特殊召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c37890974.spfilter1,1,nil,e,tp,rp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c37890974.spfilter1,1,1,nil,e,tp,rp)
	-- 将符合条件的被破坏怪兽设置为效果对象。
	Duel.SetTargetCard(g)
	-- 设置效果处理信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，获取效果对象并检查是否满足特殊召唤条件。
function c37890974.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查玩家场上是否有足够的特殊召唤区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只等级低于目标怪兽的「空牙团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c37890974.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetLevel())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
