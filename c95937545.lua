--金色の魅惑の女王
-- 效果：
-- 魔法师族怪兽3只
-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「魅惑的女王」怪兽特殊召唤，这张卡的攻击力直到下个回合的结束时上升1500。
-- ②：原本卡名包含「魅惑的女王」的自己怪兽持有的自身把怪兽装备的效果变成对方回合也能发动的效果。
-- ③：1回合1次，对方把效果发动时才能发动。场上1张卡破坏。这个回合中，自己场上的「魅惑的女王」怪兽不会被效果破坏。
local s,id,o=GetID()
-- 初始化函数，注册连接召唤手续以及卡片的三个效果
function s.initial_effect(c)
	-- 设置连接召唤手续为3只魔法师族怪兽
	aux.AddLinkProcedure(c,s.matfilter,3,3)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的卡组·墓地把1只「魅惑的女王」怪兽特殊召唤，这张卡的攻击力直到下个回合的结束时上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：原本卡名包含「魅惑的女王」的自己怪兽持有的自身把怪兽装备的效果变成对方回合也能发动的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把效果发动时才能发动。场上1张卡破坏。这个回合中，自己场上的「魅惑的女王」怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：魔法师族怪兽
function s.matfilter(c)
	return c:IsLinkRace(RACE_SPELLCASTER)
end
-- ①效果的发动条件：此卡连接召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤的过滤条件：卡名包含「魅惑的女王」的怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动准备：检查怪兽区域空位以及卡组或墓地是否存在可特召的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组或墓地是否存在至少1只满足特召条件的「魅惑的女王」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息，表示该效果包含从卡组或墓地特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- ①效果的实际处理：特殊召唤「魅惑的女王」怪兽并提升此卡攻击力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，若自己场上没有可用的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或墓地（受王家长眠之谷影响）选择1只满足条件的「魅惑的女王」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功特殊召唤该怪兽，且此卡仍在场上表侧表示存在，则继续处理攻击力上升的效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToChain() and c:IsFaceup() then
		-- 这张卡的攻击力直到下个回合的结束时上升1500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1500)
		c:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：此卡未被战斗破坏，且对方发动了效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp
end
-- ③效果的发动准备：检查场上是否有卡可以破坏，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息，表示该效果包含破坏场上1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果的实际处理：选择场上1张卡破坏，并赋予自己场上的「魅惑的女王」怪兽直到回合结束时不会被效果破坏的抗性
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	if #g>0 then
		-- 选中所选的卡片并显示选中动画
		Duel.HintSelection(g)
		-- 破坏所选的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 这个回合中，自己场上的「魅惑的女王」怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置抗性效果的影响对象为卡名包含「魅惑的女王」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 在全局环境中注册该回合内生效的抗性效果
	Duel.RegisterEffect(e1,tp)
end
