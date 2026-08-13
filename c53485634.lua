--真紅眼の遡刻竜
-- 效果：
-- ①：自己场上的7星以下的「真红眼」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地的场合才能发动。这张卡从手卡守备表示特殊召唤，尽可能把那些破坏的怪兽以和破坏时相同表示形式特殊召唤。
-- ②：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
function c53485634.initial_effect(c)
	-- ①：自己场上的7星以下的「真红眼」怪兽被对方怪兽的攻击或者对方的效果破坏送去自己墓地的场合才能发动。这张卡从手卡守备表示特殊召唤，尽可能把那些破坏的怪兽以和破坏时相同表示形式特殊召唤。
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
	-- 为这张卡注册合并延迟事件：监听怪兽被送去墓地的时机，将同一连锁中复数「真红眼」怪兽同时被破坏送去墓地的情况合并为一次延迟触发，使①效果只在连锁结束后统一诱发一次。
	aux.RegisterMergedDelayedEvent(c,53485634,EVENT_TO_GRAVE)
	-- ②：把这张卡解放才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
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
-- 筛选满足①效果发动条件的「真红眼」怪兽：破坏前在我方怪兽区表侧表示、破坏前控制者为我方、因被对方怪兽攻击或被对方效果破坏而送去墓地、等级7以下，并且能以破坏前的表示形式特殊召唤。
function c53485634.spfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
		-- 判定破坏原因：该怪兽是因对方发动的效果破坏（效果的原因玩家为对方），或是被对方怪兽的攻击战斗破坏。
		and (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp or c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		and c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsControler(tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,c:GetPreviousPosition())
end
-- ①效果的发动检测与对象设置：在发动时确认场上不存在『青眼精灵龙』的禁止复数特殊召唤效果、自己主要怪兽区有空格、此卡可以从手卡守备表示特殊召唤，且存在满足条件的被破坏「真红眼」怪兽；随后将满足条件的那些怪兽设为效果对象，并登记特殊召唤操作信息。
function c53485634.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有可用空格，以保证此卡及需要特殊召唤的怪兽有格子可以出场。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and eg:IsExists(c53485634.spfilter,1,nil,e,tp) end
	local g=eg:Filter(c53485634.spfilter,nil,e,tp)
	-- 将符合条件的被破坏「真红眼」怪兽组设为当前效果的关联对象，使它们与效果建立联系，供效果处理时确认是否仍为特殊召唤对象。
	Duel.SetTargetCard(g)
	-- 向系统登记操作信息：本效果包含将此卡从手卡特殊召唤（数量为1），用于连锁判定和效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 向系统登记操作信息：本效果包含从墓地特殊召唤这些「真红眼」怪兽（数量为g的数量），涉及从墓地离开，供『王家长眠之谷』、『屋敷童子』等效果进行响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- 效果处理时使用的过滤函数：从已关联的对象中选出仍与本效果存在联系、且能以破坏前的表示形式特殊召唤的「真红眼」怪兽。
function c53485634.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,c:GetPreviousPosition())
end
-- ①效果处理：先将此卡从手卡守备表示特殊召唤；成功后再在未被『青眼精灵龙』禁止复数特殊召唤且有空位的情况下，将被破坏的「真红眼」怪兽尽量以破坏时的表示形式特殊召唤；若格子不足则由己方选择，最后执行特殊召唤完成流程。
function c53485634.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁信息中取出发动时设置的对象卡组，并用c53485634.filter过滤出仍然有效且可特殊召唤的「真红眼」怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c53485634.filter,nil,e,tp)
	if c:IsRelateToEffect(e) then
		-- 通过分解式特殊召唤先将此卡从手卡守备表示特殊召唤；若成功才继续处理后续怪兽的特殊召唤。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 获取当前自己场上主要怪兽区域的可用空格数，用于限制接下来能特殊召唤的怪兽数量。
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if ft>0 and g:GetCount()>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
				if g:GetCount()>ft then
					-- 当可用特殊召唤对象数量超过空格数时，弹出选择提示，让玩家选择要特殊召唤哪些「真红眼」怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					g=g:Select(tp,ft,ft,nil)
				end
				local tc=g:GetFirst()
				while tc do
					-- 将被破坏的「真红眼」怪兽以破坏前相同的表示形式（由GetPreviousPosition取得）进行分解式特殊召唤。
					Duel.SpecialSummonStep(tc,0,tp,tp,false,false,tc:GetPreviousPosition())
					tc=g:GetNext()
				end
			end
		end
		-- 结束所有分解式特殊召唤步骤，完成整个特殊召唤流程，此时才处理召唤成功等时点。
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的发动条件：通过检查自己是否存在『真红眼溯刻龙』②效果的使用标志，确认本回合尚未发动过该效果。
function c53485634.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己是否有『真红眼溯刻龙』②效果的使用标志数量为0，即本回合还未用过②效果。
	return Duel.GetFlagEffect(tp,53485634)==0
end
-- ②效果的发动代价：先判断此卡是否可以作为解放对象（IsReleasable）；若是，则将解放此卡作为cost。
function c53485634.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以REASON_COST为原因解放此卡，将其送入墓地作为发动②效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ②效果的目标合法性检查：确认自己能够进行通常召唤且拥有额外召唤次数，只有满足这些条件才能发动②效果。
function c53485634.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时判定：自己是否可以进行通常召唤，以及是否已经具备额外召唤次数（用于判断能否追加召唤）。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- ②效果处理：创建一个持续到这个回合结束的领域效果EFFECT_EXTRA_SUMMON_COUNT，让「真红眼」怪兽在自己主要阶段获得追加1次通常召唤的权利；同时为自己注册本回合使用过②效果的标志。
function c53485634.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「真红眼」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(53485634,2))  --"使用「真红眼溯刻龙」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 将追加召唤效果的适用对象限定为「真红眼」字段的怪兽（0x3b为「真红眼」系列）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个追加召唤次数的效果注册给玩家tp，使其在本回合持续生效。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp注册『真红眼溯刻龙』②效果的使用标志，并在回合结束阶段重置，防止同回合再次发动②效果。
	Duel.RegisterFlagEffect(tp,53485634,RESET_PHASE+PHASE_END,0,1)
end
