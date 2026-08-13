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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上的「空牙团」怪兽被战斗或者对方的效果破坏的场合，以那1只怪兽为对象才能发动。从卡组把持有比那只怪兽的原本等级低的等级的1只「空牙团」怪兽特殊召唤。
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
-- 筛选被破坏并可作为本效果对象的「空牙团」怪兽：必须是因战斗或对方效果破坏、破坏前在我方怪兽区且由我方控制、破坏后位于墓地或除外区的「空牙团」怪兽，等级大于0，且卡组中存在等级更低且可特殊召唤的「空牙团」怪兽。
function c37890974.spfilter1(c,e,tp,rp)
	local lv=c:GetLevel()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousSetCard(0x114) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		-- 确认卡组中存在等级低于对象怪兽、卡名为「空牙团」且可以被特殊召唤的怪兽，保证后续处理时能从卡组选出符合条件的特殊召唤对象。
		and lv>0 and Duel.IsExistingMatchingCard(c37890974.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,lv)
end
-- 筛选卡组中可被特殊召唤的「空牙团」怪兽：其等级低于对象怪兽的原本等级，卡名含有「空牙团」字段，并且满足特殊召唤条件（非无视召唤条件和苏生限制）。
function c37890974.spfilter2(c,e,tp,lv)
	return c:GetLevel()<lv and c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与条件判定：若指定对象，则检查该对象是否在被破坏的怪兽集合中且满足筛选条件；若不取对象则直接确认主要怪兽区有空位且存在满足条件的破坏怪兽。
function c37890974.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c37890974.spfilter1(chkc,e,tp,rp) end
	-- 检查己方主要怪兽区是否有空位，以保证效果处理时能够特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c37890974.spfilter1,1,nil,e,tp,rp) end
	-- 显示选择对象的提示信息，提示玩家从满足条件的破坏怪兽中选择1只为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c37890974.spfilter1,1,1,nil,e,tp,rp)
	-- 将玩家选择的被破坏「空牙团」怪兽设置为当前连锁的效果对象（即取对象）。
	Duel.SetTargetCard(g)
	-- 设置本次效果的操作信息：该效果包含特殊召唤，预期从卡组特殊召唤1只怪兽到己方场上，且处理时对象尚未确定，因此targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：先取得之前选择的对象，再检查场上是否仍有空位以及对象怪兽是否仍与该效果关联（即未因离场等导致关系重置），若条件不满足则效果不处理。
function c37890974.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果记录的对象卡，即被破坏的那只「空牙团」怪兽。
	local tc=Duel.GetFirstTarget()
	-- 再次确认己方主要怪兽区仍有空位，若没有空位则无法进行特殊召唤，效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsRelateToEffect(e) then return end
	-- 显示选择要特殊召唤的卡片的提示信息，提示玩家从符合条件的卡组怪兽中进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足筛选条件（等级低于对象、字段为「空牙团」、可特殊召唤）的「空牙团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c37890974.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetLevel())
	if g:GetCount()>0 then
		-- 将选择的那只「空牙团」怪兽以表侧表示特殊召唤到己方场上（不无视召唤条件和苏生限制，按正常特殊召唤处理）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
