--見習い魔術師
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以场上1张可以放置魔力指示物的卡为对象发动。给那张卡放置1个魔力指示物。
-- ②：这张卡被战斗破坏时才能发动。从卡组把1只2星以下的魔法师族怪兽里侧守备表示特殊召唤。
function c9156135.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以场上1张可以放置魔力指示物的卡为对象发动。给那张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9156135,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c9156135.addct)
	e1:SetOperation(c9156135.addc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡被战斗破坏时才能发动。从卡组把1只2星以下的魔法师族怪兽里侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(9156135,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetTarget(c9156135.target)
	e4:SetOperation(c9156135.operation)
	c:RegisterEffect(e4)
end
c9156135.mentioned_counter={
	[0x1]=true,
}
-- 魔力指示物对象过滤条件：场上表侧表示且能放置魔力指示物的卡
function c9156135.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- ①效果发动准备：选择场上1张可放置魔力指示物的卡作为对象
function c9156135.addct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c9156135.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从场上选择1张满足条件的卡作为对象
	Duel.SelectTarget(tp,c9156135.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- ①效果处理：给目标卡放置1个魔力指示物
function c9156135.addc(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁选中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1,1)
	end
end
-- 特召过滤条件：2星以下的魔法师族怪兽
function c9156135.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果发动准备：设置从卡组里侧守备表示特召的操作信息
function c9156135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：卡组是否存在满足条件的2星以下魔法师族怪兽
		and Duel.IsExistingMatchingCard(c9156135.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1只2星以下魔法师族怪兽里侧守备表示特殊召唤
function c9156135.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的2星以下魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c9156135.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽里侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认特殊召唤的里侧表示卡
		Duel.ConfirmCards(1-tp,g)
	end
end
