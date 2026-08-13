--インフェルニティ・リフレクター
-- 效果：
-- 自己场上存在的名字带有「永火」的怪兽被战斗破坏送去墓地时，把手卡全部丢弃才能发动。那1只怪兽从自己墓地特殊召唤，给与对方基本分1000分伤害。
function c15313433.initial_effect(c)
	-- 自己场上存在的名字带有「永火」的怪兽被战斗破坏送去墓地时，把手卡全部丢弃才能发动。那1只怪兽从自己墓地特殊召唤，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c15313433.cost)
	e1:SetTarget(c15313433.target)
	e1:SetOperation(c15313433.activate)
	c:RegisterEffect(e1)
end
-- 发动代价处理：先检查手牌是否有可丢弃的卡，若有则取我方全部手卡并全部丢弃作为发动代价。
function c15313433.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价合法性检查：确认我方手牌中至少存在1张可以被丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 获取我方手牌中的所有卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 将获取到的全部手牌丢弃到墓地，丢弃原因标记为代价和丢弃。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 筛选符合条件的对象卡：需是名字带有「永火」的怪兽、在墓地、原本控制者为发动者、因战斗破坏被送去墓地、能成为效果对象且能被特殊召唤。
function c15313433.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的选择处理：从被战斗破坏送去墓地的怪兽中选择1只作为对象，并设定后续特殊召唤和伤害的操作信息。
function c15313433.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c15313433.filter(chkc,e,tp) end
	-- 发动条件检查：确认己方主要怪兽区域有空位，且被战斗破坏的怪兽组中存在满足筛选条件的对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(c15313433.filter,1,nil,e,tp) end
	-- 显示选择提示消息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c15313433.filter,1,1,nil,e,tp)
	-- 将选择的卡设置为当前连锁效果的对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：明确会对这1只对象怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：明确会对对方玩家造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,1000)
end
-- 效果处理：取得特殊召唤的对象卡，若其仍与效果关联则将其特殊召唤；随后给对方造成1000点伤害。
function c15313433.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到己方场上，不进行召唤条件与苏生限制的检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 由效果造成对方玩家1000点伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
