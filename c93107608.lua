--共鳴虫
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组选择1只攻击力1500以下的昆虫族怪兽特殊召唤到自己场上。之后卡组洗切。
function c93107608.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组选择1只攻击力1500以下的昆虫族怪兽特殊召唤到自己场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93107608,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c93107608.condition)
	e1:SetTarget(c93107608.target)
	e1:SetOperation(c93107608.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否因战斗破坏而送去墓地
function c93107608.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中攻击力1500以下且可以特殊召唤的昆虫族怪兽
function c93107608.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与合法性检测函数
function c93107608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查卡组中是否存在至少1只符合条件的怪兽
		and Duel.IsExistingMatchingCard(c93107608.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，声明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，负责将卡组中的怪兽特殊召唤到场上
function c93107608.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若自己场上已无可用怪兽区域，则不进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c93107608.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
