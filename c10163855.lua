--シェル・ナイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给与对方500伤害。
-- ②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。这个回合，自己不能把那张卡以及那些同名卡的效果发动。
function c10163855.initial_effect(c)
	-- 为卡片注册“有卡片记述”的代码列表，关联卡「化石融合」。
	aux.AddCodeList(c,59419719)
	-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10163855,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c10163855.damtg)
	e1:SetOperation(c10163855.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。这个回合，自己不能把那张卡以及那些同名卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10163855,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,10163855)
	e2:SetTarget(c10163855.thtg)
	e2:SetOperation(c10163855.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c10163855.thcon)
	c:RegisterEffect(e3)
end
-- 效果①的目标函数，用于检查发动条件和设置操作信息。
function c10163855.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定效果处理时将给予对方玩家500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①的操作函数，执行变成守备表示和给予伤害。
function c10163855.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否表侧攻击表示且与效果相关，然后将其变为表侧守备表示。
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE) then
		-- 给予对方玩家500点伤害。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 效果②的条件函数，检查卡片是否被效果送去墓地。
function c10163855.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，筛选卡组中岩石族·8星怪兽，并检查是否可加入手卡或特殊召唤。
function c10163855.filter(c,e,tp,check)
	return c:IsLevel(8) and c:IsRace(RACE_ROCK) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的目标函数，检查发动条件。
function c10163855.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有可用的主要怪兽区域空格。
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在至少一张「化石融合」。
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
		-- 检查卡组中是否存在至少一只满足条件的岩石族·8星怪兽。
		return Duel.IsExistingMatchingCard(c10163855.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 效果②的操作函数，执行检索或特殊召唤。
function c10163855.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查自己场上是否有可用的主要怪兽区域空格。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再次检查自己墓地是否存在至少一张「化石融合」。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 向玩家发送选择提示消息，提示选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	-- 让玩家从卡组中选择一只岩石族·8星怪兽。
	local tc=Duel.SelectMatchingCard(tp,c10163855.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check):GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查选择的怪兽是否不能加入手卡，或玩家选择特殊召唤选项。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
		-- 这个回合，自己不能把那张卡以及那些同名卡的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c10163855.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使得本回合不能发动特定卡的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义限制函数，检查是否不能发动特定代码的卡的效果。
function c10163855.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(e:GetLabel())
end
