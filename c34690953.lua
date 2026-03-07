--禁呪アラマティア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。在自己或者对方场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。那之后，选自己1张手卡送去墓地。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。在自己或者对方场上把1只「勇者衍生物」特殊召唤。
function c34690953.initial_effect(c)
	-- 记录该卡名记述着「勇者衍生物」的卡号
	aux.AddCodeList(c,3285552)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。在自己或者对方场上把1只「勇者衍生物」（天使族·地·4星·攻/守2000）特殊召唤。那之后，选自己1张手卡送去墓地。这个效果发动的回合，自己若非「勇者衍生物」以及有那个衍生物名记述的怪兽则不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34690953,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,34690953)
	e2:SetCost(c34690953.tkcost)
	e2:SetTarget(c34690953.tktg)
	e2:SetOperation(c34690953.tkop)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽被战斗·效果破坏的场合才能发动。在自己或者对方场上把1只「勇者衍生物」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34690953,1))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,34690954)
	e3:SetCondition(c34690953.spcon)
	e3:SetTarget(c34690953.sptg)
	e3:SetOperation(c34690953.spop)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录该玩家在该回合中特殊召唤的次数
	Duel.AddCustomActivityCounter(34690953,ACTIVITY_SPSUMMON,c34690953.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「勇者衍生物」或记述有其卡号
function c34690953.counterfilter(c)
	-- 判断卡片是否为「勇者衍生物」或记述有其卡号
	return aux.IsCodeOrListed(c,3285552)
end
-- 效果发动时检查该玩家是否已在本回合使用过此效果，若未使用则设置一个不能特殊召唤的限制效果
function c34690953.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家是否已在本回合使用过此效果
	if chk==0 then return Duel.GetCustomActivityCount(34690953,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个限制该玩家不能特殊召唤的永续效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34690953.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数，用于判断是否不能特殊召唤
function c34690953.splimit(e,c)
	return not c34690953.counterfilter(c)
end
-- 判断是否满足特殊召唤衍生物的条件并检查是否有手卡可送去墓地
function c34690953.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有空位
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	if chk==0 then return (b1 or b2)
		-- 检查是否有手卡可送去墓地
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果处理函数，执行特殊召唤衍生物并选择手卡送去墓地
function c34690953.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有空位
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	local sel=0
	if b1 or b2 then
		if b1 and b2 then
			-- 选择在自己场上或对方场上特殊召唤
			sel=Duel.SelectOption(tp,aux.Stringid(34690953,2),aux.Stringid(34690953,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
		elseif b2 then
			sel=1
		end
		local to=tp
		if sel==1 then to=1-tp end
		-- 创建「勇者衍生物」
		local token=Duel.CreateToken(tp,34690954)
		-- 将「勇者衍生物」特殊召唤
		if Duel.SpecialSummon(token,0,tp,to,false,false,POS_FACEUP)>0 then
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择要送去墓地的卡
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将选中的卡送去墓地
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end
-- 破坏时的过滤函数，判断是否为战斗或效果破坏且在自己场上
function c34690953.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 判断是否满足效果发动条件
function c34690953.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c34690953.cfilter,1,nil,tp)
end
-- 设置操作信息，表示将特殊召唤衍生物
function c34690953.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有空位
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	if chk==0 then return b1 or b2 end
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,0)
end
-- 效果处理函数，执行特殊召唤衍生物
function c34690953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
	-- 检查对方场上是否有空位
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方是否可以特殊召唤「勇者衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,3285552,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
	local sel=0
	if b1 or b2 then
		if b1 and b2 then
			-- 选择在自己场上或对方场上特殊召唤
			sel=Duel.SelectOption(tp,aux.Stringid(34690953,2),aux.Stringid(34690953,3))  --"在自己场上特殊召唤/在对方场上特殊召唤"
		elseif b2 then
			sel=1
		end
		local to=tp
		if sel==1 then to=1-tp end
		-- 创建「勇者衍生物」
		local token=Duel.CreateToken(tp,34690954)
		-- 将「勇者衍生物」特殊召唤
		Duel.SpecialSummon(token,0,tp,to,false,false,POS_FACEUP)
	end
end
