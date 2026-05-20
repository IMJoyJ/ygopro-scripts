--黒蠍団召集
-- 效果：
-- 当自己场上存在表侧表示的「首领 扎鲁格」时这张卡才能发动。可以从手卡里将名称中含有「黑蝎」字样的怪兽全部特殊召唤上场。（同名怪兽只能特殊召唤1只）
function c68191243.initial_effect(c)
	-- 当自己场上存在表侧表示的「首领 扎鲁格」时这张卡才能发动。可以从手卡里将名称中含有「黑蝎」字样的怪兽全部特殊召唤上场。（同名怪兽只能特殊召唤1只）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c68191243.con)
	e1:SetTarget(c68191243.tg)
	e1:SetOperation(c68191243.op)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「首领 扎鲁格」
function c68191243.cfilter(c)
	return c:IsFaceup() and c:IsCode(76922029)
end
-- 发动条件：检查自己场上是否存在表侧表示的「首领 扎鲁格」
function c68191243.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「首领 扎鲁格」
	return Duel.IsExistingMatchingCard(c68191243.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：手牌中可以特殊召唤的「黑蝎」怪兽
function c68191243.filter(c,e,tp)
	return c:IsSetCard(0x1a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与检测：检查怪兽区域空位数以及手牌中是否存在可特殊召唤的「黑蝎」怪兽，并设置特殊召唤的操作信息
function c68191243.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1只可以特殊召唤的「黑蝎」怪兽
		and Duel.IsExistingMatchingCard(c68191243.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置特殊召唤的操作信息，预计从手牌特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：获取可用怪兽区域数量，考虑「青眼精灵龙」的限制，从手牌中选择并特殊召唤卡名互不相同的「黑蝎」怪兽
function c68191243.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手牌中所有可以特殊召唤的「黑蝎」怪兽
	local g=Duel.GetMatchingGroup(c68191243.filter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合条件的怪兽中选择1到ft张卡名互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
