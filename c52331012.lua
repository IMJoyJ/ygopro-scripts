--鉄獣戦線 銀弾のルガル
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段才能发动。从自己的手卡·墓地把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到持有者手卡。
-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降自己场上的怪兽的种族种类×300。
function c52331012.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2到3张满足种族为兽族·兽战士族·鸟兽族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,3)
	c:EnableReviveLimit()
	-- ①：对方主要阶段才能发动。从自己的手卡·墓地把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52331012,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52331012)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c52331012.spcon)
	e1:SetTarget(c52331012.sptg)
	e1:SetOperation(c52331012.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降自己场上的怪兽的种族种类×300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52331012,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52331013)
	e2:SetTarget(c52331012.atktg)
	e2:SetOperation(c52331012.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：当前回合不是玩家回合，且当前阶段为主要阶段1或主要阶段2
function c52331012.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合不是玩家回合
	return Duel.GetTurnPlayer()~=tp
		-- 且当前阶段为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 特殊召唤的怪兽过滤器：满足种族为兽族·兽战士族·鸟兽族、等级不超过4星、可以被特殊召唤的怪兽
function c52331012.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点判断：检查玩家手牌和墓地是否存在满足条件的怪兽，且场上存在空位
function c52331012.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c52331012.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：检查是否有足够空间进行特殊召唤，选择满足条件的怪兽并特殊召唤，同时使其效果无效化并在结束阶段返回手卡
function c52331012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52331012.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使该怪兽效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(52331012,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册一个持续到结束阶段的效果，用于在结束阶段将特殊召唤的怪兽送回手牌
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c52331012.thcon)
		e3:SetOperation(c52331012.thop)
		-- 将该效果注册给玩家
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断是否为当前特殊召唤的怪兽，防止重复处理
function c52331012.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(52331012)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 将特殊召唤的怪兽送回手牌
function c52331012.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽送回手牌
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
-- 攻击力变更的过滤器：满足场上正面表示且种族不为0的怪兽
function c52331012.atkfilter(c)
	return c:IsFaceup() and c:GetRace()~=0
end
-- 效果发动时点判断：检查玩家场上是否存在正面表示的怪兽，以及对方场地上是否存在正面表示的怪兽
function c52331012.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在正面表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52331012.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场地上是否存在正面表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：计算玩家场上怪兽的种族种类数，并对对方所有正面表示怪兽造成相当于该数量乘以300的攻击力下降效果
function c52331012.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上正面表示的怪兽组
	local tg=Duel.GetMatchingGroup(c52331012.atkfilter,tp,LOCATION_MZONE,0,nil)
	local ct=tg:GetClassCount(Card.GetRace)
	-- 获取对方场上的正面表示怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为对方怪兽添加攻击力下降效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
