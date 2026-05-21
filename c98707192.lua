--ゴーストリック・マリー
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，战斗或者卡的效果让自己受到伤害时，把这张卡从手卡丢弃才能发动。从卡组把1只名字带有「鬼计」的怪兽里侧守备表示特殊召唤。「鬼计妖魔·玛丽」的这个效果1回合只能使用1次。
function c98707192.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c98707192.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98707192,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c98707192.postg)
	e2:SetOperation(c98707192.posop)
	c:RegisterEffect(e2)
	-- 此外，战斗或者卡的效果让自己受到伤害时，把这张卡从手卡丢弃才能发动。从卡组把1只名字带有「鬼计」的怪兽里侧守备表示特殊召唤。「鬼计妖魔·玛丽」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(98707192,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCountLimit(1,98707192)
	e3:SetCondition(c98707192.condition)
	e3:SetCost(c98707192.cost)
	e3:SetTarget(c98707192.target)
	e3:SetOperation(c98707192.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c98707192.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制的条件：自己场上不存在表侧表示的「鬼计」怪兽（此时不能召唤）
function c98707192.sumcon(e)
	-- 检查自己场上是否存在表侧表示的「鬼计」怪兽，若不存在则返回true（触发不能召唤的限制）
	return not Duel.IsExistingMatchingCard(c98707192.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的发动准备，检查自身是否能转为里侧守备表示，并注册1回合1次的使用标记
function c98707192.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(98707192)==0 end
	c:RegisterFlagEffect(98707192,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将自身表示形式变更
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的执行函数，若自身仍在场上且表侧表示，则将其转为里侧守备表示
function c98707192.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变更为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果发动条件：自己受到战斗或者卡的效果伤害时
function c98707192.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果发动代价：将手牌中的这张卡丢弃
function c98707192.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 作为发动代价，将手牌的这张卡丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可以里侧守备表示特殊召唤的「鬼计」怪兽
function c98707192.filter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动准备：检查自己场上是否有空怪兽位，以及卡组中是否存在可特殊召唤的「鬼计」怪兽
function c98707192.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的「鬼计」怪兽
		and Duel.IsExistingMatchingCard(c98707192.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1只「鬼计」怪兽以里侧守备表示特殊召唤，并向对方确认
function c98707192.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则处理终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「鬼计」怪兽
	local g=Duel.SelectMatchingCard(tp,c98707192.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
