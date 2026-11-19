--N・マリン・ドルフィン
-- 效果：
-- 这个卡名在规则上也当作「新空间侠·水波海豚」使用。这张卡用「新空间侠界限」的效果才能特殊召唤。
-- ①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。
function c78734254.initial_effect(c)
	-- 记录这张卡的卡文上记载了「新空间侠·水波海豚」的卡名。
	aux.AddCodeList(c,17955766)
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
-- ①效果的代价处理函数：检查并从自己手卡丢弃1张卡。
function c78734254.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可行性检测：检查自己手卡中是否存在至少1张可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从自己手卡中选择1张卡并作为发动代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的目标处理函数：检查对方手卡数量是否大于0。
function c78734254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查对方手卡是否存在至少1张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 过滤函数：判断场上的怪兽是否为表侧表示且攻击力在指定攻击力（atk）以上。
function c78734254.filter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- ①效果的效果处理函数：确认对方手卡并从中选1只怪兽，若自己场上有攻击力不低于该怪兽的怪兽则将其破坏并给与对方500点伤害，最后洗切对方手卡。
function c78734254.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家的所有手卡卡片组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 将对方手卡展示给自己玩家确认。
		Duel.ConfirmCards(tp,g)
		-- 向自己发送选择提示，提示玩家从对方手卡中选择1只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(78734254,1))
		local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		local tc=tg:GetFirst()
		if tc then
			local atk=tc:GetAttack()
			-- 检查选中的怪兽攻击力数值有效，且自己场上存在至少1只攻击力大于等于该数值的表侧怪兽。
			if tc:IsAttackAbove(0) and Duel.IsExistingMatchingCard(c78734254.filter,tp,LOCATION_MZONE,0,1,nil,atk) then
				-- 将选中的对方手卡中的怪兽卡以效果破坏。
				Duel.Destroy(tc,REASON_EFFECT)
				-- 给与对方玩家500点效果伤害。
				Duel.Damage(1-tp,500,REASON_EFFECT)
			end
		end
		-- 确认并处理完毕后洗切对方的手卡。
		Duel.ShuffleHand(1-tp)
	end
end
