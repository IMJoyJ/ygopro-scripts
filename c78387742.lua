--フェイク・ヒーロー
-- 效果：
-- 从自己手卡特殊召唤1只名字带有「元素英雄」的怪兽。那只怪兽不能攻击，这个回合的结束阶段时回到持有者手卡。
function c78387742.initial_effect(c)
	-- 从自己手卡特殊召唤1只名字带有「元素英雄」的怪兽。那只怪兽不能攻击，这个回合的结束阶段时回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c78387742.target)
	e1:SetOperation(c78387742.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中名字带有「元素英雄」且可以特殊召唤的怪兽
function c78387742.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的检测，检查怪兽区域是否有空位，以及手卡中是否存在可特殊召唤的「元素英雄」怪兽
function c78387742.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只满足过滤条件的「元素英雄」怪兽
		and Duel.IsExistingMatchingCard(c78387742.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示该效果会从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果处理，从手卡特殊召唤1只「元素英雄」怪兽，并对其施加不能攻击和结束阶段回到手卡的效果
function c78387742.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「元素英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c78387742.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 那只怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		-- 这个回合的结束阶段时回到持有者手卡。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetOperation(c78387742.retop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		tc:RegisterEffect(e2,true)
	end
end
-- 结束阶段时将该怪兽送回持有者手卡的效果处理函数
function c78387742.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该怪兽因效果送回持有者的手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
