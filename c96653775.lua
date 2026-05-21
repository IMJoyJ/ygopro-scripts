--ナチュル・パンプキン
-- 效果：
-- 对方场上有怪兽存在的场合这张卡召唤成功时，可以从手卡把1只名字带有「自然」的怪兽特殊召唤。
function c96653775.initial_effect(c)
	-- 对方场上有怪兽存在的场合这张卡召唤成功时，可以从手卡把1只名字带有「自然」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96653775,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c96653775.spcon)
	e1:SetTarget(c96653775.sptg)
	e1:SetOperation(c96653775.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：对方场上有怪兽存在
function c96653775.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
end
-- 过滤函数：手牌中名字带有「自然」且可以特殊召唤的怪兽
function c96653775.filter(c,e,tp)
	return c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动目标：检查怪兽区域空位及手牌中是否存在可特殊召唤的「自然」怪兽
function c96653775.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手牌中存在至少1只满足过滤条件的「自然」怪兽
		and Duel.IsExistingMatchingCard(c96653775.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理：从手牌特殊召唤1只「自然」怪兽
function c96653775.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上已无可用怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件的「自然」怪兽
	local g=Duel.SelectMatchingCard(tp,c96653775.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
