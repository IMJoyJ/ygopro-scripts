--シェル・ナイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，给与对方500伤害。
-- ②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。这个回合，自己不能把那张卡以及那些同名卡的效果发动。
function c10163855.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「化石融合」(59419719)的卡名
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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把1只岩石族·8星怪兽加入手卡。自己墓地有「化石融合」存在的场合，也能不加入手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10163855,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 效果①的Target函数：在发动时始终返回可发动，并设置造成500伤害的操作信息
function c10163855.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置给与对方500伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①的Operation函数：若这张卡为表侧攻击表示且与效果有联系，将其变为表侧守备表示后给与对方500伤害
function c10163855.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否表侧攻击表示且仍与效果关联，并尝试将其变为表侧守备表示
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
		-- 以效果伤害形式给与对方玩家500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 效果②（送去墓地触发分支）的Condition函数：检查这张卡是否因效果原因被送去墓地
function c10163855.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：筛选卡组中8星、岩石族且可以加入手卡或（满足条件时）可以特殊召唤的怪兽
function c10163855.filter(c,e,tp,check)
	return c:IsLevel(8) and c:IsRace(RACE_ROCK) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果②的Target函数：检测墓地是否存在「化石融合」与怪兽区空位情况，并确认卡组中有符合条件的岩石族·8星怪兽
function c10163855.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查己方主要怪兽区是否还有可用空位（用于判断是否能特殊召唤）
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查己方墓地是否存在「化石融合」(59419719)
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
		-- 检查己方卡组中是否存在至少1张满足检索或特召条件的8星岩石族怪兽
		return Duel.IsExistingMatchingCard(c10163855.filter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 效果②的Operation函数：从卡组选1只8星岩石族怪兽加入手卡或（墓地有「化石融合」时）特殊召唤，并限制本回合不能发动该卡及其同名卡的效果
function c10163855.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新检测效果处理时己方场上是否仍有可用的怪兽区空位
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 重新检测效果处理时己方墓地是否存在「化石融合」(59419719)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,59419719)
	-- 向己方玩家发送选择要操作的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的8星岩石族怪兽并取出该卡
	local tc=Duel.SelectMatchingCard(tp,c10163855.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check):GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若该怪兽无法加入手卡，或玩家在加入手卡(1190)与特殊召唤(1152)之间选择了特殊召唤，则执行特召分支
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 以效果将选中的怪兽加入其持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的怪兽
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
		-- 为己方玩家注册持续到回合结束的禁止发动效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 效果限制判定函数：禁止己方发动与所选怪兽卡号相同的卡片的效果
function c10163855.aclimit(e,re,tp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(e:GetLabel())
end
