--シェル・ナイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给与对方500伤害。
-- ②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。这个回合，自己不能把那张卡以及那些同名卡的效果发动。
function c10163855.initial_effect(c)
	-- 将卡片「化石融合」的卡号放入此卡的关联卡片列表中
	aux.AddCodeList(c,59419719)
	-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给予对方500伤害。
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
-- 召唤成功时伤害效果的发动准备
function c10163855.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为给予对方玩家500点效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 召唤成功时伤害效果的执行
function c10163855.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡在场上表侧攻击表示存在，且与效果关联，则把此卡变更为表侧守备表示成功后
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
		-- 给予对方500点效果伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 检查是否因为效果被送去墓地
function c10163855.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检索或特殊召唤的岩石族·8星怪兽的过滤条件
function c10163855.filter(c,e,tp,check)
	return c:IsLevel(8) and c:IsRace(RACE_ROCK) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 检索或特殊召唤效果的发动准备及对象检测
function c10163855.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有空怪兽区域
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己墓地是否存在「化石融合」
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
		-- 检查卡组是否存在满足过滤条件的岩石族·8星怪兽
		return Duel.IsExistingMatchingCard(c10163855.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 检索或特殊召唤效果的执行
function c10163855.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空怪兽区域
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在「化石融合」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 向玩家发送提示，请选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择卡组中1张满足条件的岩石族·8星怪兽
	local tc=Duel.SelectMatchingCard(tp,c10163855.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check):GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若满足特殊召唤条件，且玩家选择特殊召唤（或无法加入手卡）
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示选中的怪兽
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
		-- 注册该玩家本回合不能发动同名卡效果的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制该卡片及同名卡的效果发动的过滤条件
function c10163855.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(e:GetLabel())
end
