--シャーク・ザ・クルー
-- 效果：
-- 自己场上表侧表示存在的这张卡被对方的卡的效果破坏的场合，可以从自己卡组把最多2只4星以下的水属性怪兽在自己场上特殊召唤。
function c20358953.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡被对方的卡的效果破坏的场合，可以从自己卡组把最多2只4星以下的水属性怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20358953,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c20358953.spcon)
	e1:SetTarget(c20358953.sptg)
	e1:SetOperation(c20358953.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：本卡被对方玩家的卡的效果破坏，且破坏前是自己场上表侧表示存在的怪兽。具体为：破坏原因包含效果、导致破坏的玩家为对方、破坏前控制者为自己、破坏前位于场上且为表侧表示。
function c20358953.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 定义可从卡组特殊召唤的怪兽筛选条件：等级4以下、水属性，并且可以被当前效果特殊召唤。
function c20358953.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点（目标选择前）的合法性判定：自己怪兽区域有空位，且卡组中存在至少1只满足条件的怪兽。
function c20358953.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用的空格，若无空格则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足筛选条件的怪兽，作为效果能否发动的必要条件。
		and Duel.IsExistingMatchingCard(c20358953.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果涉及特殊召唤，预计从卡组特殊召唤最多2只怪兽到自己场上，供连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：计算可特殊召唤数量并实际进行特殊召唤。先取得怪兽区域空位数，若空位不足或受青眼精灵龙效果限制则减少可召唤数量，然后选择1到相应数量的卡特殊召唤。
function c20358953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己主要怪兽区域的当前可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1到ft只满足条件的怪兽，ft已受空位数量、最多2只限制及青眼精灵龙效果影响。
	local g=Duel.SelectMatchingCard(tp,c20358953.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
