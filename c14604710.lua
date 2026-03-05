--星遺物の胎導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只9星怪兽特殊召唤。
-- ●以自己场上1只9星怪兽为对象才能发动。和那只怪兽是原本的种族·属性不同的2只9星怪兽从卡组特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c14604710.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●从手卡把1只9星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14604710,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14604710+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14604710.target1)
	e1:SetOperation(c14604710.activate1)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●以自己场上1只9星怪兽为对象才能发动。和那只怪兽是原本的种族·属性不同的2只9星怪兽从卡组特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14604710,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,14604710+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c14604710.target2)
	e2:SetOperation(c14604710.activate2)
	c:RegisterEffect(e2)
end
-- 用于过滤手卡中可以特殊召唤的9星怪兽
function c14604710.spfilter1(c,e,tp)
	return c:IsLevel(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的第一个子效果的发动时处理函数
function c14604710.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：手卡中是否存在至少1张9星怪兽
		and Duel.IsExistingMatchingCard(c14604710.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的第一个子效果的发动处理函数
function c14604710.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择1张9星怪兽
	local g=Duel.SelectMatchingCard(tp,c14604710.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于过滤卡组中可以特殊召唤的9星怪兽（需与目标怪兽种族和属性不同）
function c14604710.tgfilter2(c,e,tp)
	if c:IsFacedown() or not c:IsLevel(9) then return false end
	-- 获取卡组中所有满足条件的9星怪兽
	local g=Duel.GetMatchingGroup(c14604710.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,c)
	return g:GetClassCount(Card.GetCode)>1
end
-- 用于过滤卡组中可以特殊召唤的9星怪兽（需与目标怪兽种族和属性不同）
function c14604710.spfilter2(c,e,tp,tc)
	return c:IsLevel(9) and c:GetOriginalRace()~=tc:GetOriginalRace() and c:GetOriginalAttribute()~=tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的第二个子效果的发动时处理函数
function c14604710.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14604710.tgfilter2(chkc,e,tp) end
	-- 判断是否满足发动条件：玩家未被「王家长眠之谷」等效果影响
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断是否满足发动条件：场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 判断是否满足发动条件：场上是否存在至少1只9星怪兽作为对象
		and Duel.IsExistingTarget(c14604710.tgfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择场上1只9星怪兽作为效果对象
	Duel.SelectTarget(tp,c14604710.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果①的第二个子效果的发动处理函数
function c14604710.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取卡组中所有满足条件的9星怪兽
	local g=Duel.GetMatchingGroup(c14604710.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,tc)
	-- 判断是否满足发动条件：玩家未被「王家长眠之谷」等效果影响
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetCode)>1 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 从满足条件的卡中选择2张卡名不同的怪兽
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		local sc=g1:GetFirst()
		while sc do
			-- 使特殊召唤的怪兽不能攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			sc:RegisterFlagEffect(14604710,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			sc=g1:GetNext()
		end
		g1:KeepAlive()
		-- 设置在结束阶段破坏特殊召唤怪兽的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(g1)
		e2:SetCondition(c14604710.descon)
		e2:SetOperation(c14604710.desop)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 用于判断怪兽是否为特殊召唤效果的对象
function c14604710.desfilter(c,fid)
	return c:GetFlagEffectLabel(14604710)==fid
end
-- 判断是否满足结束阶段破坏的条件
function c14604710.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c14604710.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段破坏操作
function c14604710.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c14604710.desfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
