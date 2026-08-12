--シェル・ナイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给与对方500伤害。
-- ②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。这个回合，自己不能把那张卡以及那些同名卡的效果发动。
function c10163855.initial_effect(c)
	-- 记录这张卡上记载着「化石融合」（卡号59419719）的卡名
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
-- ①效果的目标函数：发动条件恒为真，并设置伤害效果的操作信息
function c10163855.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将给对方造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ①效果的处理函数：这张卡变成守备表示成功后，给与对方500伤害
function c10163855.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡表侧攻击表示且仍与效果关联，则把它变成表侧守备表示，成功才继续处理
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
		-- 以效果原因给与对方500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- ②效果（送去墓地版）的发动条件：这张卡是被效果送去墓地的场合
function c10163855.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：筛选等级8的岩石族怪兽，且能加入手卡，或（墓地有「化石融合」时）能被特殊召唤
function c10163855.filter(c,e,tp,check)
	return c:IsLevel(8) and c:IsRace(RACE_ROCK) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果的目标函数：检查自己怪兽区有空位且墓地有「化石融合」作为特殊召唤条件，并确认卡组存在满足条件的怪兽
function c10163855.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己主要怪兽区是否有可用空格（特殊召唤前提之一）
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且自己墓地存在「化石融合」（卡号59419719）
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
		-- 确认卡组存在至少1只满足条件的岩石族·8星怪兽，效果才能发动
		return Duel.IsExistingMatchingCard(c10163855.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- ②效果的处理函数：从卡组选1只岩石族·8星怪兽，根据条件选择特殊召唤或加入手卡，然后注册本回合不能发动其及同名卡效果的限制
function c10163855.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否有可用空格（特殊召唤前提之一）
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在「化石融合」（卡号59419719）
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 向玩家提示“请选择要操作的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让自己玩家从卡组选择1只满足条件的岩石族·8星怪兽
	local tc=Duel.SelectMatchingCard(tp,c10163855.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check):GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 且这张卡不能加入手卡，或玩家选择了“特殊召唤”选项（而非“加入手卡”）
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的怪兽在自己场上以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的怪兽以效果原因加入自己的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 让对方确认这张加入手卡的卡
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
		-- 把“不能发动那张卡及其同名卡效果”的限制效果注册给自己玩家，直到回合结束
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制判定函数：被发动的卡的卡号与记录的卡号相同（那张卡及同名卡）时禁止发动
function c10163855.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(e:GetLabel())
end
