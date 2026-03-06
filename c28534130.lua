--転生炎獣の炎虞
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只「转生炎兽」怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材把1只「转生炎兽」连接怪兽连接召唤。这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。
-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「转生炎兽」连接怪兽为对象才能发动。那只怪兽回到额外卡组。
function c28534130.initial_effect(c)
	-- ①：从手卡把1只「转生炎兽」怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材把1只「转生炎兽」连接怪兽连接召唤。这个回合，这个效果连接召唤的怪兽不能攻击，不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28534130+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28534130.target)
	e1:SetOperation(c28534130.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己墓地1只「转生炎兽」连接怪兽为对象才能发动。那只怪兽回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28534130,0))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 将这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c28534130.tdtg)
	e2:SetOperation(c28534130.tdop)
	c:RegisterEffect(e2)
end
-- 连接召唤的过滤函数，用于判断是否可以连接召唤
function c28534130.lkfilter(c,mc)
	return c:IsSetCard(0x119) and c:IsLinkSummonable(nil,mc)
end
-- 特殊召唤的过滤函数，用于判断是否可以特殊召唤
function c28534130.spfilter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在可以连接召唤的「转生炎兽」连接怪兽
		and Duel.IsExistingMatchingCard(c28534130.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 效果发动的条件判断，检查是否可以进行2次特殊召唤且场上存在空位
function c28534130.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在可以特殊召唤的「转生炎兽」怪兽
		and Duel.IsExistingMatchingCard(c28534130.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果处理函数，执行特殊召唤和连接召唤
function c28534130.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「转生炎兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c28534130.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，若失败则返回
	if not tc or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end
	local c=e:GetHandler()
	-- 使特殊召唤的怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 刷新场上信息
	Duel.AdjustAll()
	if not tc:IsLocation(LOCATION_MZONE) then return end
	-- 获取可以连接召唤的「转生炎兽」连接怪兽
	local tg=Duel.GetMatchingGroup(c28534130.lkfilter,tp,LOCATION_EXTRA,0,nil,tc)
	if tg:GetCount()>0 then
		-- 提示玩家选择要连接召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 设置连接召唤成功后的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e3:SetOperation(c28534130.regop)
		sc:RegisterEffect(e3)
		-- 执行连接召唤
		Duel.LinkSummon(tp,sc,nil,tc)
	end
end
-- 连接召唤成功后设置效果
function c28534130.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetOwner()
	local c=e:GetHandler()
	-- 设置连接召唤的怪兽不能攻击和发动效果
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e2,true)
	e:Reset()
end
-- 墓地「转生炎兽」连接怪兽的过滤函数
function c28534130.tdfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 设置效果发动时的目标选择
function c28534130.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28534130.tdfilter(chkc) end
	-- 检查是否存在满足条件的墓地「转生炎兽」连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c28534130.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地「转生炎兽」连接怪兽
	local g=Duel.SelectTarget(tp,c28534130.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要将怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 效果处理函数，执行将怪兽送回额外卡组
function c28534130.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回额外卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
