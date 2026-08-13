--海皇龍 ポセイドラ
-- 效果：
-- 把自己场上3只3星以下的水属性怪兽解放才能发动。这张卡从手卡或者墓地特殊召唤。这个效果特殊召唤成功时，场上的魔法·陷阱卡全部回到持有者手卡。这个效果让卡3张以上回到手卡的场合，对方场上的全部怪兽的攻击力下降回到手卡的卡数量×300的数值。
function c47826112.initial_effect(c)
	-- 把自己场上3只3星以下的水属性怪兽解放才能发动。这张卡从手卡或者墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47826112,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c47826112.spcost)
	e1:SetTarget(c47826112.sptg)
	e1:SetOperation(c47826112.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，场上的魔法·陷阱卡全部回到持有者手卡。这个效果让卡3张以上回到手卡的场合，对方场上的全部怪兽的攻击力下降回到手卡的卡数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47826112,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47826112.thcon)
	e2:SetTarget(c47826112.thtg)
	e2:SetOperation(c47826112.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选出等级3以下、水属性的怪兽，且该怪兽的控制者为tp或为表侧表示，作为可解放素材的候选。
function c47826112.cfilter(c,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsControler(tp) or c:IsFaceup())
end
-- 代价处理：从可解放的怪兽组中过滤出符合条件的候选，检测能否选出3只且解放后仍有空格，然后让玩家选择3只并解放作为发动代价。
function c47826112.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家tp可解放的怪兽组，并过滤出所有满足条件（3星以下水属性，且己方控制或表侧表示）的怪兽作为候选组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c47826112.cfilter,nil,tp)
	-- 在代价检测阶段，检查候选组中是否存在3只怪兽，且这些怪兽解放后主怪兽区仍有空位（aux.mzctcheckrel同时验证可解放性和空间）。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,3,3,tp) end
	-- 显示“请选择要解放的卡”的提示信息，引导玩家选择解放素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从候选组中让玩家选择3只怪兽，选择时再次用aux.mzctcheckrel确认解放后仍有空位，确保能特殊召唤。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,3,3,tp)
	-- 调用辅助函数处理使用了代替解放效果（如暗影敌托邦）的次数，确保额外解放计数正确消耗。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的3只怪兽作为效果发动代价解放（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 发动目标检测：确认这张卡目前可以被特殊召唤；若可以，则设置特殊召唤的操作信息。
function c47826112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果会把卡组中的这张卡（数量1）特殊召唤，用于后续时点检测和连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：检查这张卡仍与效果关联（未离场或未被无效），然后执行特殊召唤。
function c47826112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的主怪兽区，召唤类型标记为SUMMON_VALUE_SELF，以便后续效果识别是“这个效果特殊召唤成功”。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 诱发条件：判定这张卡的特殊召唤类型是否为自身效果的特殊召唤（SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF），即只有用这个效果特殊召唤成功时才触发。
function c47826112.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：筛选场上的魔法陷阱卡，且该卡能够加入手卡（不受‘不能回手卡’限制）。
function c47826112.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动目标处理：无取对象，设置操作信息为将场上所有符合条件的魔法·陷阱卡全部返回持有者手卡。
function c47826112.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上（双方）所有满足条件的魔法·陷阱卡，作为弹回手牌的对象。
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：分类为回手牌，目标为g中的所有卡，数量为g的数量，表明效果处理时将把这些卡全部弹回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：先将场上所有符合条件的魔法陷阱卡送回持有者手卡，再统计实际回手数量；若回手数≥3，则令对方场上的表侧表示怪兽攻击力下降相应数值。
function c47826112.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段重新获取场上的所有符合条件的魔法陷阱卡（防止发动后场上情况变化）。
	local g=Duel.GetMatchingGroup(c47826112.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些卡以效果原因（REASON_EFFECT）返回持有者手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	if ct>=3 then
		-- 获取对方场上所有表侧表示怪兽，作为攻击力下降效果的适用对象。
		local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=mg:GetFirst()
		while tc do
			-- 对方场上的全部怪兽的攻击力下降回到手卡的卡数量×300的数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-ct*300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=mg:GetNext()
		end
	end
end
