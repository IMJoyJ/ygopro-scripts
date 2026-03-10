--神星なる波動
-- 效果：
-- ①：1回合1次，自己主要阶段以及对方战斗阶段才能把这个效果发动。从手卡把1只「星骑士」怪兽特殊召唤。
function c5026221.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建并注册一个诱发即时效果，允许在特定阶段发动，将手卡的「星骑士」怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5026221,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c5026221.condition)
	e2:SetTarget(c5026221.target2)
	e2:SetOperation(c5026221.operation)
	c:RegisterEffect(e2)
end
-- 判断当前是否为自己的主要阶段或对方的战斗阶段
function c5026221.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
	end
end
-- 过滤函数，用于筛选手卡中可以特殊召唤的「星骑士」怪兽
function c5026221.filter(c,e,tp)
	return c:IsSetCard(0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标，检查是否有满足条件的「星骑士」怪兽可特殊召唤
function c5026221.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只符合条件的「星骑士」怪兽
		and Duel.IsExistingMatchingCard(c5026221.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行效果的操作部分，选择并特殊召唤符合条件的怪兽
function c5026221.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的「星骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c5026221.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
