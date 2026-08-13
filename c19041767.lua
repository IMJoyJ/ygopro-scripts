--デュアル・サモナー
-- 效果：
-- 对方的结束阶段时只有1次支付500基本分才能发动。把手卡或者自己场上表侧表示存在的1只二重怪兽通常召唤。此外，这张卡1回合只有1次不会被战斗破坏。
function c19041767.initial_effect(c)
	-- 此外，这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c19041767.valcon)
	c:RegisterEffect(e1)
	-- 对方的结束阶段时只有1次支付500基本分才能发动。把手卡或者自己场上表侧表示存在的1只二重怪兽通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19041767,0))  --"通常召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c19041767.condition)
	e2:SetCost(c19041767.cost)
	e2:SetTarget(c19041767.target)
	e2:SetOperation(c19041767.operation)
	c:RegisterEffect(e2)
end
-- 判定本效果适用的破坏是否为战斗破坏：当破坏原因中包含战斗破坏时返回真，从而使该卡获得1回合1次的战斗破坏抗性。
function c19041767.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 筛选可通常召唤的二重怪兽：必须是二重怪兽，并且满足不占用通常召唤次数的表侧攻击表示召唤或里侧守备表示放置条件。
function c19041767.filter(c)
	return c:IsType(TYPE_DUAL) and (c:IsSummonable(true,nil) or c:IsMSetable(true,nil))
end
-- e2的发动条件：当前玩家不是回合玩家，即只在对方回合才能发动。结合触发阶段为结束阶段，满足“对方的结束阶段时”。
function c19041767.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果控制者不是当前回合玩家，则条件成立，用于限定只能在对方回合的结束阶段发动。
	return tp~=Duel.GetTurnPlayer()
end
-- 发动效果的代价：需要支付500基本分，能够支付时才能发动，发动时实际扣除500LP。
function c19041767.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：若chk为0，返回能否支付500基本分，用于确认发动代价是否满足。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付代价：扣除发动玩家500基本分。
	Duel.PayLPCost(tp,500)
end
-- 效果发动时的目标选择及操作信息设置：确认手牌或自己场上表侧表示存在至少1只可通常召唤的二重怪兽，并设置本次连锁包含召唤操作。
function c19041767.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌和自己场上表侧表示是否存在至少1只满足c19041767.filter条件的二重怪兽，作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c19041767.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 将操作信息设定为包含召唤（CATEGORY_SUMMON），数量为1，用于连锁处理时的效果检测与应对。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：从手牌或自己场上表侧表示的二重怪兽中选择1只，按玩家选择的表示形式进行不占用通常召唤次数的通常召唤（表侧攻击表示召唤或里侧守备表示放置）。
function c19041767.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要召唤的卡”的选卡提示，用于后续的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 效果处理时从手牌和自己场上表侧表示的二重怪兽中选择1只满足可通常召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19041767.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		-- 根据目标怪兽能否表侧攻击表示召唤和里侧守备表示放置的情况决定表示形式：若两者皆可则让玩家选择；若能表侧召唤则表侧召唤；否则实行里侧守备放置。
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			-- 以不占用通常召唤次数的方式，将选择的怪兽表侧攻击表示通常召唤。
			Duel.Summon(tp,tc,true,nil)
		else
			-- 以不占用通常召唤次数的方式，将选择的怪兽里侧守备表示放置（SET）。
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
