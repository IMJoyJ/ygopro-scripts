--カオスエンドマスター
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以从卡组把1只5星以上而攻击力1600以下的怪兽特殊召唤。
function c46609443.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以从卡组把1只5星以上而攻击力1600以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46609443,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c46609443.spcon)
	e1:SetTarget(c46609443.sptg)
	e1:SetOperation(c46609443.spop)
	c:RegisterEffect(e1)
end
-- 触发条件判定：此次被战斗破坏送去墓地的怪兽仅有1只，且导致其被破坏的卡是这张卡，并且该怪兽被送去墓地且破坏原因包含战斗破坏。
function c46609443.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 筛选条件：被选择的怪兽必须是攻击力1600以下、等级5以上，并且可以被当前效果特殊召唤。
function c46609443.filter(c,e,tp)
	return c:IsAttackBelow(1600) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标判定：在效果发动时（chk==0）检查自己主要怪兽区是否有可用空格，同时卡组中是否存在满足筛选条件的怪兽。
function c46609443.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，若有空格才可能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1张满足c46609443.filter条件的怪兽，即5星以上且攻击力1600以下、可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c46609443.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息登记为从卡组特殊召唤1只怪兽，供其他效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若处理时场上仍有可用怪兽区，则由玩家从卡组选择1只符合条件的怪兽进行表侧表示特殊召唤。
function c46609443.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用的主要怪兽区空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组中选出1张满足筛选条件（5星以上、攻击力1600以下、可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c46609443.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧表示特殊召唤到自己场上（进行召唤条件与苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
