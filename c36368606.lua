--サイバネット・リフレッシュ
-- 效果：
-- ①：对方的电子界族怪兽的攻击宣言时才能发动。双方的主要怪兽区域的怪兽全部破坏。这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
-- ②：对方怪兽的效果发动时，把墓地的这张卡除外才能发动。自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
function c36368606.initial_effect(c)
	-- ①：对方的电子界族怪兽的攻击宣言时才能发动。双方的主要怪兽区域的怪兽全部破坏。这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c36368606.condition)
	e1:SetTarget(c36368606.target)
	e1:SetOperation(c36368606.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的效果发动时，把墓地的这张卡除外才能发动。自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36368606.immcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36368606.immtg)
	e2:SetOperation(c36368606.immop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：对方电子界族怪兽攻击宣言时
function c36368606.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方电子界族怪兽攻击宣言时
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttacker():IsRace(RACE_CYBERSE)
end
-- 破坏对象过滤器：主要怪兽区域的怪兽
function c36368606.desfilter(c)
	return c:GetSequence()<5
end
-- 效果处理准备：检查是否有主要怪兽区域的怪兽，若有则设置破坏操作信息
function c36368606.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有主要怪兽区域的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取主要怪兽区域的怪兽组
	local g=Duel.GetMatchingGroup(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏双方主要怪兽区域的怪兽，并在结束阶段特殊召唤破坏的电子界族连接怪兽
function c36368606.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取主要怪兽区域的怪兽组
	local g=Duel.GetMatchingGroup(c36368606.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 若存在怪兽且破坏成功，则注册结束阶段特殊召唤效果
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的怪兽组
		local og=Duel.GetOperatedGroup()
		og:KeepAlive()
		-- ①：对方的电子界族怪兽的攻击宣言时才能发动。双方的主要怪兽区域的怪兽全部破坏。这个回合的结束阶段把这个效果破坏的电子界族连接怪兽尽可能从墓地往持有者场上特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetOperation(c36368606.spop)
		-- 注册结束阶段特殊召唤效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤对象过滤器：墓地的电子界族连接怪兽
function c36368606.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_GRAVE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetControler())
end
-- 结束阶段特殊召唤处理：按持有者分别特殊召唤电子界族连接怪兽
function c36368606.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(c36368606.spfilter,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 遍历双方玩家
	for p in aux.TurnPlayers() do
		local tg=g:Filter(Card.IsControler,nil,p)
		-- 获取该玩家场上空位数
		local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(p,59822133) then ft=1 end
		if tg:GetCount()>ft then
			tg=tg:Select(tp,ft,ft,nil)
		end
		-- 遍历该玩家的特殊召唤对象
		for tc in aux.Next(tg) do
			-- 特殊召唤一张怪兽
			Duel.SpecialSummonStep(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 效果发动条件：对方怪兽发动效果时
function c36368606.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 免疫效果对象过滤器：场上正面表示的电子界族连接怪兽
function c36368606.immfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK)
end
-- 效果处理准备：检查是否有场上正面表示的电子界族连接怪兽
function c36368606.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有场上正面表示的电子界族连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36368606.immfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：使场上正面表示的电子界族连接怪兽在回合结束前不受效果影响
function c36368606.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上正面表示的电子界族连接怪兽组
	local g=Duel.GetMatchingGroup(c36368606.immfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- ②：对方怪兽的效果发动时，把墓地的这张卡除外才能发动。自己场上的电子界族连接怪兽直到回合结束时不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c36368606.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 免疫效果的过滤函数：不免疫自身效果
function c36368606.efilter(e,te,c)
	return te:GetOwner()~=c
end
