--暗黒のミミック LV1
-- 效果：
-- 反转：从卡组抽1张卡。此外，自己的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「暗黑之宝箱怪 LV3」
function c74713516.initial_effect(c)
	-- 反转：从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c74713516.target)
	e1:SetOperation(c74713516.operation)
	c:RegisterEffect(e1)
	-- 此外，自己的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「暗黑之宝箱怪 LV3」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74713516,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c74713516.spcon)
	e2:SetCost(c74713516.spcost)
	e2:SetTarget(c74713516.sptg)
	e2:SetOperation(c74713516.spop)
	c:RegisterEffect(e2)
end
c74713516.lvup={1102515}
-- 反转抽卡效果的发动准备与效果处理
function c74713516.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家以效果抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 反转抽卡效果的实际效果处理
function c74713516.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 特殊召唤效果的发动条件判断
function c74713516.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 特殊召唤效果的发动代价处理
function c74713516.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤手卡或卡组中可以被LV效果特殊召唤的「暗黑之宝箱怪 LV3」
function c74713516.spfilter(c,e,tp)
	return c:IsCode(1102515) and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_LV,tp,true,true)
end
-- 特殊召唤效果的发动准备
function c74713516.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查怪兽区域是否有空位（因为自身作为代价送去墓地会空出一个怪兽区域，所以要求当前怪兽区域空位数大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查自己的手卡或卡组中是否存在至少1张满足条件的「暗黑之宝箱怪 LV3」
		and Duel.IsExistingMatchingCard(c74713516.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的实际效果处理
function c74713516.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1张满足条件的「暗黑之宝箱怪 LV3」
	local g=Duel.SelectMatchingCard(tp,c74713516.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以LV效果、无视召唤条件且无视苏生限制地在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
