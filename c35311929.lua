--陽竜果フォンリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡被怪兽的效果从卡组送去墓地的场合才能发动。这张卡特殊召唤。自己场上有其他的植物族怪兽存在的场合，可以再选场上1只怪兽那个攻击力·守备力变成一半。
-- ②：1回合1次，场上的这张卡被战斗·效果破坏的场合，可以作为代替从卡组把1只植物族怪兽送去墓地。
function c35311929.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡被怪兽的效果从卡组送去墓地的场合才能发动。这张卡特殊召唤。自己场上有其他的植物族怪兽存在的场合，可以再选场上1只怪兽那个攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35311929,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,35311929)
	e1:SetCondition(c35311929.spcon)
	e1:SetTarget(c35311929.sptg)
	e1:SetOperation(c35311929.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，场上的这张卡被战斗·效果破坏的场合，可以作为代替从卡组把1只植物族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetCountLimit(1)
	e2:SetTarget(c35311929.desreptg)
	c:RegisterEffect(e2)
end
-- ①的发动条件：此次送去墓地的原因包含效果，且该效果是怪兽效果，并且这张卡在被送去墓地之前位于卡组。
function c35311929.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_MONSTER)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- ①发动时的合法检查：我方主要怪兽区有空位，且这张卡可以特殊召唤。
function c35311929.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行特殊召唤的操作信息，对象为这张卡，数量为1，便于其他卡正确连锁或判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：筛选表侧表示且种族为植物族的怪兽；调用时可通过额外参数排除这张卡自身。
function c35311929.checkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- ①效果处理：若这张卡仍与效果关联且特殊召唤成功，且场上存在表侧怪兽、自己场上存在这张卡以外的表侧植物族怪兽，则询问玩家是否再选1只怪兽把攻击力·守备力变成一半；选择是则中断处理，选1只表侧怪兽并对其攻击力·守备力分别施加减半效果。
function c35311929.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认我方主要怪兽区仍有空格，若没有则不再继续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 确认这张卡仍与发动时的效果保持关联后，将其以表侧表示特殊召唤到自己场上；SpecialSummon返回值非0表示特殊召唤成功。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查双方场上是否存在至少1只表侧表示怪兽，作为后续选择攻击力·守备力减半对象的候选。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在这张卡以外的表侧植物族怪兽，以满足“有其他植物族怪兽存在的场合”这一追加条件。
		and Duel.IsExistingMatchingCard(c35311929.checkfilter,tp,LOCATION_MZONE,0,1,c)
		-- 询问玩家是否发动追加处理：再选场上1只怪兽，使其攻击力·守备力变成一半。
		and Duel.SelectYesNo(tp,aux.Stringid(35311929,1)) then  --"是否选1只怪兽攻击力·守备力变成一半？"
			-- 中断当前效果处理，使特殊召唤之后的追加减半处理被视为新的处理，避免错失时点或关联问题。
			Duel.BreakEffect()
			-- 从双方场上的表侧表示怪兽中选择1只，作为攻击力·守备力变成一半的对象。
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 展示所选怪兽，并将其记录为“被选择为对象”，使相关时点效果能够正确触发。
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if tc then
				-- 那个攻击力变成一半（对应原文：那个攻击力·守备力变成一半）。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(math.ceil(tc:GetAttack()/2))
				tc:RegisterEffect(e1)
				-- 那个守备力变成一半（对应原文：那个攻击力·守备力变成一半）。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(math.ceil(tc:GetDefense()/2))
				tc:RegisterEffect(e2)
			end
	end
end
-- ②代替破坏的检索过滤：从卡组选择1只植物族怪兽送去墓地，要求该卡是植物族且能被送去墓地。
function c35311929.desrepfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- ②的发动条件：这张卡在场上因战斗或效果被破坏，且不是已经被代替破坏置换过的破坏，同时卡组中存在符合条件的植物族怪兽可送去墓地。
function c35311929.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查卡组中是否存在至少1只符合条件的植物族怪兽可用于代替破坏。
		and Duel.IsExistingMatchingCard(c35311929.desrepfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动②的代替破坏效果：通过从卡组把1只植物族怪兽送去墓地来作为破坏的代替。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 在选择要送去墓地的卡之前，给出“请选择要送去墓地的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足条件的植物族怪兽，用于代替破坏送去墓地。
		local g=Duel.SelectMatchingCard(tp,c35311929.desrepfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的植物族怪兽送去墓地，原因标记为效果与代替，表示这是代替破坏的送墓。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
