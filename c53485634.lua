--真紅眼の遡刻竜
-- 效果：
-- ①：自己场上的7星以下的「真红眼」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地的场合才能发动。这张卡从手卡守备表示特殊召唤，尽可能把那些破坏的怪兽以和破坏时相同表示形式特殊召唤。
-- ②：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.initial_effect(c)
	-- 效果原文内容：①：自己场上的7星以下的「真红眼」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地的场合才能发动。这张卡从手卡守备表示特殊召唤，尽可能把那些破坏的怪兽以和破坏时相同表示形式特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53485634,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+53485634)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c53485634.sptg)
	e1:SetOperation(c53485634.spop)
	c:RegisterEffect(e1)
	-- 规则层面操作：注册一个合并延迟事件处理器，用于将同一时间点内发生的多个同类游戏事件合并为单次自定义事件触发，防止效果重复发动。
	aux.RegisterMergedDelayedEvent(c,53485634,EVENT_TO_GRAVE)
	-- 效果原文内容：②：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53485634,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c53485634.sumcon)
	e2:SetCost(c53485634.sumcost)
	e2:SetTarget(c53485634.sumtg)
	e2:SetOperation(c53485634.sumop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：定义一个过滤函数，用于筛选满足条件的被破坏怪兽，包括其位置、控制者、破坏原因、种族、等级和可特殊召唤性。
function c53485634.spfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		-- 规则层面操作：判断该破坏是由对方效果或战斗引起的，确保是对方造成的破坏。
		and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,c:GetPreviousPosition())
end
-- 规则层面操作：检测是否满足发动条件，包括未受青眼精灵龙影响、场上存在空位、自身可特殊召唤且目标怪兽存在。
function c53485634.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 规则层面操作：检查玩家场上是否有足够的怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and eg:IsExists(c53485634.spfilter,1,nil,e,tp) end
	local g=eg:Filter(c53485634.spfilter,nil,e,tp)
	-- 规则层面操作：将符合条件的被破坏怪兽设置为连锁处理的目标卡片。
	Duel.SetTargetCard(g)
	-- 规则层面操作：设置本次连锁的操作信息，表明将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 规则层面操作：设置本次连锁的操作信息，表明将从墓地特殊召唤目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 规则层面操作：定义一个过滤函数，用于筛选可参与特殊召唤的目标卡片。
function c53485634.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,c:GetPreviousPosition())
end
-- 规则层面操作：处理效果发动时的特殊召唤流程，包括自身和被破坏怪兽的特殊召唤步骤。
function c53485634.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：从连锁信息中获取目标卡片组并进行过滤。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c53485634.filter,nil,e,tp)
	if c:IsRelateToEffect(e) then
		-- 规则层面操作：尝试特殊召唤自身到场上，若成功则继续处理后续逻辑。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 规则层面操作：获取玩家当前可用的怪兽区域数量。
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>0 and g:GetCount()>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
				if g:GetCount()>ft then
					-- 规则层面操作：提示玩家选择要特殊召唤的卡片。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					g=g:Select(tp,ft,ft,nil)
				end
				local tc=g:GetFirst()
				while tc do
					-- 规则层面操作：按原表示形式特殊召唤单张卡片。
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,tc:GetPreviousPosition())
					tc=g:GetNext()
				end
			end
		end
		-- 规则层面操作：完成所有特殊召唤步骤，确保效果正确结算。
		Duel.SpecialSummonComplete()
	end
end
-- 效果原文内容：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否已使用过该效果，防止重复发动。
	return Duel.GetFlagEffect(tp,53485634)==0
end
-- 效果原文内容：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 规则层面操作：以解放自身为代价支付效果的费用。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果原文内容：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检测玩家是否可以进行通常召唤和额外召唤。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- 效果原文内容：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(53485634,2))  --"使用「真红眼溯刻龙」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 规则层面操作：设置效果的目标为拥有特定种族（真红眼）的卡片。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将该效果注册到全局环境中生效。
	Duel.RegisterEffect(e1,tp)
	-- 规则层面操作：为玩家注册一个标识效果，用于限制该效果只能发动一次。
	Duel.RegisterFlagEffect(tp,53485634,RESET_PHASE+PHASE_END,0,1)
end
