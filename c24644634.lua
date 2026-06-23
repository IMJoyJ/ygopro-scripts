--ナチュル・ホワイトオーク
-- 效果：
-- 这张卡成为对方的卡的效果的对象时才能发动。把自己场上表侧表示存在的这张卡送去墓地，从自己卡组把2只4星以下的名字带有「自然」的怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，自己的结束阶段时破坏。
function c24644634.initial_effect(c)
	-- 创建一个诱发即时效果，当对方的卡的效果对象为这张卡时可以发动，效果类型为Quick-O，发动地点为场上，条件为spcon，代价为spcost，目标为sptg，效果处理为spop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24644634,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c24644634.spcon)
	e1:SetCost(c24644634.spcost)
	e1:SetTarget(c24644634.sptg)
	e1:SetOperation(c24644634.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方玩家发动效果且该效果为取对象效果，且这张卡在连锁对象中
function c24644634.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(e:GetHandler())
end
-- 效果发动代价：将这张卡送去墓地作为代价
function c24644634.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数：筛选4星以下且属于自然卡组且可以特殊召唤的怪兽
function c24644634.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：检测玩家是否未被青眼精灵龙效果影响，且场上存在空位，且卡组存在至少2只满足条件的怪兽
function c24644634.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组是否存在至少2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c24644634.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置效果处理信息，确定要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：检测玩家是否被青眼精灵龙效果影响，检测场上是否至少有2个空位，获取满足条件的怪兽数组，选择2只怪兽特殊召唤，为特殊召唤的怪兽添加不能攻击宣言效果，为特殊召唤的怪兽添加标记，注册结束阶段破坏效果
function c24644634.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检测场上是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c24644634.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		local fid=e:GetHandler():GetFieldID()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的2只怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		local tc=sg:GetFirst()
		tc:RegisterFlagEffect(24644634,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		-- 为特殊召唤的怪兽添加不能攻击宣言效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
		tc:RegisterFlagEffect(24644634,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		local e2=e1:Clone()
		tc:RegisterEffect(e2)
		sg:KeepAlive()
		-- 注册结束阶段破坏效果，使特殊召唤的怪兽在结束阶段时被破坏
		local de=Effect.CreateEffect(e:GetHandler())
		de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		de:SetCode(EVENT_PHASE+PHASE_END)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetCountLimit(1)
		de:SetLabel(fid)
		de:SetLabelObject(sg)
		de:SetCondition(c24644634.descon)
		de:SetOperation(c24644634.desop)
		-- 将破坏效果注册到玩家
		Duel.RegisterEffect(de,tp)
	end
end
-- 过滤函数：检测怪兽是否具有指定标记
function c24644634.desfilter(c,fid)
	return c:GetFlagEffectLabel(25935625)==fid
end
-- 破坏效果的触发条件：当前回合玩家为效果发动者，且特殊召唤的怪兽存在
function c24644634.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前回合玩家是否为效果发动者
	if Duel.GetTurnPlayer()~=tp then return end
	local g=e:GetLabelObject()
	if not g:IsExists(c24644634.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 破坏效果处理：将具有指定标记的怪兽破坏
function c24644634.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c24644634.desfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
