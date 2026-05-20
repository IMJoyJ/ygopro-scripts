--鋼鉄の巨兵
-- 效果：
-- 岩石族3星怪兽×2
-- 只要这张卡在场上表侧表示存在，这张卡不受这张卡以外的怪兽的效果影响。1回合1次，把这张卡1个超量素材取除才能发动。这张卡的守备力直到结束阶段时上升1000，这个回合，对方的卡的效果发生的对自己的效果伤害变成0。这个效果在对方回合也能发动。
function c57043117.initial_effect(c)
	-- 设置超量召唤手续：岩石族3星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),3,2)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，这张卡不受这张卡以外的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c57043117.efilter)
	c:RegisterEffect(e1)
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的守备力直到结束阶段时上升1000，这个回合，对方的卡的效果发生的对自己的效果伤害变成0。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetDescription(aux.Stringid(57043117,0))  --"守备上升"
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCost(c57043117.cost)
	e2:SetOperation(c57043117.operation)
	c:RegisterEffect(e2)
end
-- 免疫效果过滤：判断是否为这张卡以外的怪兽发动的效果
function c57043117.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 发动代价：取除这张卡的1个超量素材
function c57043117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：使自身守备力上升1000，并使本回合对方造成的卡片效果伤害变成0
function c57043117.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的守备力直到结束阶段时上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这个回合，对方的卡的效果发生的对自己的效果伤害变成0。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(c57043117.damval)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册将对方效果伤害变为0的全局效果
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册免疫效果伤害的标记效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 伤害计算过滤：若伤害来源为对方的效果，则将伤害值修改为0
function c57043117.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
