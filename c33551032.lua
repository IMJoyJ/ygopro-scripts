--アンブラル・アンフォーム
-- 效果：
-- 这张卡的攻击让这张卡被战斗破坏送去墓地时，可以从卡组把2只名字带有「阴影」的怪兽特殊召唤。「阴影无形鬼」的效果1回合只能使用1次。
function c33551032.initial_effect(c)
	-- 这张卡的攻击让这张卡被战斗破坏送去墓地时，可以从卡组把2只名字带有「阴影」的怪兽特殊召唤。「阴影无形鬼」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33551032,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,33551032)
	e1:SetCondition(c33551032.spcon)
	e1:SetTarget(c33551032.sptg)
	e1:SetOperation(c33551032.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定这张卡是否因为被攻击而战斗破坏并送入了墓地，即自身为攻击被破坏的那只怪兽且位于墓地。
function c33551032.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此次战斗的攻击者为此卡，此卡当前在墓地且被战斗破坏（满足“这张卡的攻击让这张卡被战斗破坏送去墓地”的触发条件）。
	return Duel.GetAttacker()==c and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 筛选卡组中可以特殊召唤的名字带有「阴影」的怪兽，作为本次特殊召唤的候选。
function c33551032.spfilter(c,e,tp)
	return c:IsSetCard(0x87) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点检测：若己方不受“不能把2只以上的怪兽同时特殊召唤”效果影响（如青眼精灵龙），且主要怪兽区有2个以上空位，且卡组存在2只以上可特殊召唤的「阴影」怪兽，则效果可发动；并设置效果信息为从卡组特殊召唤2只怪兽。
function c33551032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方主要怪兽区剩余可用空格大于1，以确保能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只符合条件的「阴影」怪兽（即满足spfilter的卡），确保能进行特殊召唤。
		and Duel.IsExistingMatchingCard(c33551032.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 声明本次连锁的操作信息：效果分类为特殊召唤，预定从卡组特殊召唤2只怪兽，对象在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若不受青眼精灵龙限制且主要怪兽区有2个以上空位，则从卡组选出全部符合条件的「阴影」怪兽，由玩家从中选择2只，以表侧攻击表示特殊召唤到己方场上。
function c33551032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若主要怪兽区可用空格不超过1个，则无法同时特殊召唤2只，效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 从卡组获取所有符合spfilter条件的「阴影」怪兽组成一个组，供玩家选择。
	local g=Duel.GetMatchingGroup(c33551032.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<2 then return end
	-- 给予玩家选择提示，显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将选中的2只怪兽以表侧表示特殊召唤到己方场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
