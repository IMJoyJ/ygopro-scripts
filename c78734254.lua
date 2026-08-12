--N・マリン・ドルフィン
-- 效果：
-- 这个卡名在规则上也当作「新空间侠·水波海豚」使用。这张卡用「新空间侠界限」的效果才能特殊召唤。
-- ①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。
function c78734254.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「新空间侠界限」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78734254,0))  --"确认手卡"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c78734254.cost)
	e2:SetTarget(c78734254.target)
	e2:SetOperation(c78734254.activate)
	c:RegisterEffect(e2)
	-- 这个卡名在规则上也当作「新空间侠·水波海豚」使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_ADD_CODE)
	e4:SetValue(17955766)
	c:RegisterEffect(e4)
end
-- 定义效果发动的代价函数：丢弃1张手卡。
function c78734254.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果发动的目标函数：确认对方手卡中是否存在卡片。
function c78734254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方手卡数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 过滤函数：筛选自己场上表侧表示且攻击力在指定数值以上的怪兽。
function c78734254.filter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 定义效果处理函数：确认对方手卡并选择1只怪兽，若自己场上有攻击力在其之上的怪兽则将其破坏并给予对方伤害。
function c78734254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 让己方玩家确认对方的所有手卡。
		Duel.ConfirmCards(tp,g)
		-- 提示玩家选择1张卡片。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(78734254,1))
		local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		local tc=tg:GetFirst()
		if tc then
			local atk=tc:GetAttack()
			-- 检查选中的怪兽是否具有攻击力，且自己场上是否存在攻击力在选中的怪兽以上的表侧表示怪兽。
			if tc:IsAttackAbove(0) and Duel.IsExistingMatchingCard(c78734254.filter,tp,LOCATION_MZONE,0,1,nil,atk) then
				-- 因效果破坏选中的对方手卡中的怪兽。
				Duel.Destroy(tc,REASON_EFFECT)
				-- 给予对方玩家500点伤害。
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
		end
		-- 重新洗切对方的手卡。
		Duel.ShuffleHand(1-tp)
	end
end
