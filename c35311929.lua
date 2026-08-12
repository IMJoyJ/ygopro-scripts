--陽竜果フォンリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡被怪兽的效果从卡组送去墓地的场合才能发动。这张卡特殊召唤。自己场上有其他的植物族怪兽存在的场合，可以再选场上1只怪兽那个攻击力·守备力变成一半。
-- ②：1回合1次，场上的这张卡被战斗·效果破坏的场合，可以作为代替从卡组把1只植物族怪兽送去墓地。
function c35311929.initial_effect(c)
	-- ①：这张卡被怪兽的效果从卡组送去墓地的场合才能发动。这张卡特殊召唤。自己场上有其他的植物族怪兽存在的场合，可以再选场上1只怪兽那个攻击力·守备力变成一半。
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
-- 判断是否满足效果①的发动条件：被怪兽的效果送去墓地且是从卡组送去墓地
function c35311929.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_MONSTER)
		and e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 设置效果①的发动条件：可以特殊召唤
function c35311929.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 用于判断场上是否有植物族怪兽的过滤函数
function c35311929.checkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果①的处理流程：特殊召唤自身并可能改变场上一只怪兽的攻守
function c35311929.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断自身是否可以特殊召唤
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断自己场上是否有至少一只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 判断自己场上是否有至少一只植物族怪兽
		and Duel.IsExistingMatchingCard(c35311929.checkfilter,tp,LOCATION_MZONE,0,1,c)
		-- 询问玩家是否发动效果①的后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(35311929,1)) then  --"是否选1只怪兽攻击力·守备力变成一半？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 选择场上一只表侧表示的怪兽作为目标
			local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 显示选中的怪兽作为效果处理对象
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			if tc then
				-- 将目标怪兽的攻击力变为原来的一半
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(math.ceil(tc:GetAttack()/2))
				tc:RegisterEffect(e1)
				-- 将目标怪兽的守备力变为原来的一半
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(math.ceil(tc:GetDefense()/2))
				tc:RegisterEffect(e2)
			end
	end
end
-- 用于判断卡组中是否有可送去墓地的植物族怪兽的过滤函数
function c35311929.desrepfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 判断是否满足效果②的发动条件：被战斗或效果破坏且卡组中有植物族怪兽
function c35311929.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 判断卡组中是否存在满足条件的植物族怪兽
		and Duel.IsExistingMatchingCard(c35311929.desrepfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 询问玩家是否发动效果②
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择一张植物族怪兽从卡组送去墓地
		local g=Duel.SelectMatchingCard(tp,c35311929.desrepfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的植物族怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
