--H・C アンブッシュ・ソルジャー
-- 效果：
-- 自己的准备阶段时，把场上的这张卡解放才能发动。可以从自己的手卡·墓地选「英豪挑战者 伏击兵」以外的最多2只名字带有「英豪挑战者」的怪兽特殊召唤。「英豪挑战者 伏击兵」的这个效果1回合只能使用1次。这个效果特殊召唤成功时，可以通过把墓地的这张卡从游戏中除外，自己场上的全部名字带有「英豪挑战者」的怪兽的等级变成1星。
function c92609670.initial_effect(c)
	-- 自己的准备阶段时，把场上的这张卡解放才能发动。可以从自己的手卡·墓地选「英豪挑战者 伏击兵」以外的最多2只名字带有「英豪挑战者」的怪兽特殊召唤。「英豪挑战者 伏击兵」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92609670,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,92609670)
	e1:SetCondition(c92609670.spcon)
	e1:SetCost(c92609670.spcost)
	e1:SetTarget(c92609670.sptg)
	e1:SetOperation(c92609670.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，可以通过把墓地的这张卡从游戏中除外，自己场上的全部名字带有「英豪挑战者」的怪兽的等级变成1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92609670,1))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+92609670)
	e2:SetCost(c92609670.lvcost)
	e2:SetTarget(c92609670.lvtg)
	e2:SetOperation(c92609670.lvop)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动条件函数：当前回合玩家是自己
function c92609670.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤效果的Cost（发动代价）函数：解放场上的这张卡
function c92609670.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·墓地中「英豪挑战者 伏击兵」以外的「英豪挑战者」怪兽，且可以特殊召唤
function c92609670.filter(c,e,tp)
	return not c:IsCode(92609670) and c:IsSetCard(0x106f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target（发动准备/目标选择）函数
function c92609670.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域（因为自身作为Cost被解放，所以可用区域数需要大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且自己手卡或墓地存在至少1只满足特殊召唤条件的「英豪挑战者」怪兽
		and Duel.IsExistingMatchingCard(c92609670.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的Operation（效果处理）函数
function c92609670.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可以特殊召唤的怪兽数量（自己场上空余怪兽区域与最大值2的较小值）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡或墓地选择最多ft只满足条件的「英豪挑战者」怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c92609670.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 触发自定义事件，用于检测“这个效果特殊召唤成功时”的时点
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+92609670,e,0,tp,tp,0)
	end
end
-- 等级变化效果的Cost（发动代价）函数：把墓地的这张卡除外
function c92609670.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsAbleToRemove() end
	-- 将墓地的这张卡表侧表示除外作为发动的代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己场上表侧表示、等级在2星以上的「英豪挑战者」怪兽
function c92609670.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x106f) and c:IsLevelAbove(2)
end
-- 等级变化效果的Target（发动准备/目标选择）函数
function c92609670.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示且等级在2星以上的「英豪挑战者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92609670.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 等级变化效果的Operation（效果处理）函数
function c92609670.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级在2星以上的「英豪挑战者」怪兽
	local g=Duel.GetMatchingGroup(c92609670.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部名字带有「英豪挑战者」的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
