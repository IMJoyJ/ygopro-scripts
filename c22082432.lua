--神の怒り
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把基本分支付一半，把自己场上1只怪兽解放才能发动。自己的手卡·除外状态的1只「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成4000，不能攻击，下个回合的结束阶段回到手卡。
-- ②：这张卡从场上送去墓地的场合发动。选自己场上1只「太阳神之翼神龙」，那只怪兽以外的场上的怪兽全部送去墓地。
local s,id,o=GetID()
-- 该函数为卡片初始化效果注册：①效果为可发动的魔法卡效果，②效果为从场上送去墓地时触发的必发效果。
function s.initial_effect(c)
	-- 登记此卡上记载的卡名「太阳神之翼神龙」（卡号10000010），用于相关规则判定。
	aux.AddCodeList(c,10000010)
	-- ①效果：把基本分支付一半，把自己场上1只怪兽解放才能发动。自己的手卡·除外状态的1只「太阳神之翼神龙」无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成4000，不能攻击，下个回合的结束阶段回到手卡。
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
	-- ②效果：这张卡从场上送去墓地的场合发动。选自己场上1只「太阳神之翼神龙」，那只怪兽以外的场上的怪兽全部送去墓地。
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
-- 解放过滤函数：检查怪兽被解放后自己场上是否仍有空位，且该怪兽是自己的表侧或里侧表示怪兽（可解放）。
function s.cfilter(c,tp)
	-- 满足被解放后主怪兽区仍有空余格子，并且该怪兽是自己控制或是表侧表示，才可作为解放候选。
	return Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动代价：支付一半基本分，并从自己场上解放1只满足条件的怪兽；chk=0时只检查能否支付代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在代价检查阶段，确认自己场上是否存在1只可解放且解放后不占满怪兽区的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 支付当前LP一半的数值作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	-- 从自己场上选择1只符合解放条件的怪兽作为解放对象。
	local rg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因为代价（REASON_COST）。
	Duel.Release(rg,REASON_COST)
end
-- 特殊召唤候选过滤：选择手卡或除外状态的表侧表示的「太阳神之翼神龙」，且允许无视召唤条件进行特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ①效果的发动目标判断与操作信息设定：确认存在可特殊召唤的「太阳神之翼神龙」且自己有怪兽区空位；同时标记本次特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查手卡或除外状态是否存在1只满足特殊召唤条件的「太阳神之翼神龙」。
			return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		else
			-- 检查自己场上是否有可用的怪兽区空格。
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 同时确认手卡或除外状态存在可特殊召唤的「太阳神之翼神龙」。
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		end
	end
	e:SetLabel(0)
	-- 设定效果处理时要从手卡或除外区特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
-- ①效果处理：特殊召唤手卡/除外状态的「太阳神之翼神龙」，并对其附加攻击力·守备力变为4000、不能攻击、下个结束阶段回手卡的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己场上仍有怪兽区空格，否则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示，让玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡或除外区选择1只符合条件的「太阳神之翼神龙」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的「太阳神之翼神龙」无视召唤条件以表侧攻击表示特殊召唤，并确认召唤成功。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
		-- 该效果特殊召唤的怪兽的攻击力·守备力变成4000，并为其打上标记以便下个回合结束阶段回到手卡。
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
		-- 该效果特殊召唤的怪兽不能攻击。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		-- 设置下个回合结束阶段将该怪兽回到手卡的持续效果；同时包含②效果的后半部分：选自己场上1只「太阳神之翼神龙」，那只怪兽以外的场上的怪兽全部送去墓地。
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 记录下个回合的回合数，用于结束阶段判定回到手卡的时机。
		e4:SetLabel(Duel.GetTurnCount()+1)
		e4:SetLabelObject(tc)
		e4:SetCondition(s.thcon)
		e4:SetOperation(s.thop)
		-- 在场地区域注册该持续效果，使其在每个结束阶段检查是否回手。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 回手效果的条件：该怪兽仍带有特殊召唤标记，且当前回合数等于预设的下个结束阶段对应回合数；若标记消失则取消该效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		-- 判断当前回合是否为预先记录的下个回合，以此决定是否到结束阶段回手。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 回手处理：将特殊召唤的「太阳神之翼神龙」返回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将标记的怪兽送回持有者手卡。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果的发动条件：这张卡从场上（而非其他区域）被送去墓地。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②效果选择对象的过滤：自己场上表侧表示的「太阳神之翼神龙」。
function s.ccfilter(c)
	return c:IsFaceup() and c:IsCode(10000010)
end
-- ②效果的发动目标检查：满足发动条件后，设定把场上怪兽送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次效果将场上（双方怪兽区）1只以上的怪兽送去墓地的操作信息，用于连锁判定和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- ②效果处理：选自己场上1只「太阳神之翼神龙」，将该怪兽以外的场上怪兽全部送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，让玩家选择自己场上1只「太阳神之翼神龙」作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「太阳神之翼神龙」。
	local g=Duel.SelectMatchingCard(tp,s.ccfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的「太阳神之翼神龙」显示选择动画并记录其为对象。
		Duel.HintSelection(g)
		-- 取得场上除该「太阳神之翼神龙」以外的所有怪兽。
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,g)
		if sg:GetCount()>0 then
			-- 将选出的其他怪兽全部以效果原因送去墓地。
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
