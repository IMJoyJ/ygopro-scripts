--神の怒り
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把基本分支付一半，把自己场上1只怪兽解放才能发动。自己的手卡·除外状态的1只「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成4000，不能攻击，下个回合的结束阶段回到手卡。
-- ②：这张卡从场上送去墓地的场合发动。选自己场上1只「太阳神之翼神龙」，那只怪兽以外的场上的怪兽全部送去墓地。
local s,id,o=GetID()
-- 初始化效果，注册两个效果：①效果和②效果
function s.initial_effect(c)
	-- 记录该卡拥有「太阳神之翼神龙」的卡名
	aux.AddCodeList(c,10000010)
	-- ①：把基本分支付一半，把自己场上1只怪兽解放才能发动。自己的手卡·除外状态的1只「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成4000，不能攻击，下个回合的结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。选自己场上1只「太阳神之翼神龙」，那只怪兽以外的场上的怪兽全部送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 检查场上是否有可解放的怪兽
function s.cfilter(c,tp)
	-- 检查场上是否有可解放的怪兽
	return Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付一半LP并选择1只怪兽进行解放
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 支付一半LP
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 选择1只怪兽进行解放
	local rg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(rg,REASON_COST)
end
-- 筛选可特殊召唤的「太阳神之翼神龙」
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置①效果的发动条件和目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查是否有满足条件的「太阳神之翼神龙」
			return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		else
			-- 检查场上是否有空怪兽区
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查是否有满足条件的「太阳神之翼神龙」
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 设置操作信息，表示将特殊召唤1只「太阳神之翼神龙」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- 执行①效果的处理，特殊召唤「太阳神之翼神龙」并设置其属性
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只「太阳神之翼神龙」进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤怪兽的攻击力为4000并设置守备力为4000，设置不能攻击，下个回合结束时回到手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(4000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 设置特殊召唤怪兽不能攻击
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		-- 设置特殊召唤怪兽在下个回合结束时回到手卡
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置下个回合的回合数
		e4:SetLabel(Duel.GetTurnCount()+1)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.thcon)
		e4:SetOperation(s.thop)
		-- 注册效果，用于在下个回合结束时将怪兽送回手卡
		Duel.RegisterEffect(e4,tp)
	end
end
-- 判断是否为下个回合结束阶段
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判断是否为下个回合
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 将怪兽送回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽送回手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 判断该卡是否从场上送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选场上「太阳神之翼神龙」
function s.ccfilter(c)
	return c:IsFaceup() and c:IsCode(10000010)
end
-- 设置②效果的目标
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将场上所有怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 执行②效果的处理，选择1只「太阳神之翼神龙」并将其以外的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只「太阳神之翼神龙」
	local g=Duel.SelectMatchingCard(tp,s.ccfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选择对象的动画
		Duel.HintSelection(g)
		-- 获取场上所有怪兽
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,g)
		if sg:GetCount()>0 then
			-- 将场上所有怪兽送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
