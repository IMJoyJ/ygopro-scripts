--アヌビスの審判
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有其他的魔法·陷阱卡3张以上存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。自己场上有「王家的神殿」存在的场合，可以再把对方场上的怪兽全部破坏。那个场合，再给与对方破坏的怪兽的原本攻击力合计数值一半的伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，并添加关联卡片密码
function s.initial_effect(c)
	-- 将「王家的神殿」（卡号29762407）加入到这张卡的关联卡片列表中
	aux.AddCodeList(c,29762407)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有其他的魔法·陷阱卡3张以上存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。自己场上有「王家的神殿」存在的场合，可以再把对方场上的怪兽全部破坏。那个场合，再给与对方破坏的怪兽的原本攻击力合计数值一半的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除这张卡以外的3张以上的魔法·陷阱卡，且该连锁是由对方玩家发动的
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,3,e:GetHandler(),TYPE_SPELL+TYPE_TRAP) and rp==1-tp
		-- 并且对方发动的效果是魔法·陷阱卡的发动（卡片发动），且该发动可以被无效
		and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 定义效果发动的目标与处理检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：无效该连锁的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 如果发动的卡与该效果有关联，则设置效果处理信息：破坏该卡
	if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0) end
end
-- 定义效果发动的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，若成功且该卡仍存在，则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 获取对方场上的所有怪兽
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 若对方场上有怪兽存在，且自己场上存在表侧表示的「王家的神殿」
		if #sg>0 and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,29762407)
			-- 询问玩家是否选择发动追加效果（破坏对方场上的全部怪兽）
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽全部破坏？"
			-- 中断当前效果处理，使后续的破坏和伤害处理与前面的无效破坏不视为同时处理
			Duel.BreakEffect()
			-- 破坏对方场上的所有怪兽，并检查是否有怪兽被成功破坏
			if Duel.Destroy(sg,REASON_EFFECT)~=0 then
				-- 获取本次操作中实际被破坏的卡片组
				local og=Duel.GetOperatedGroup()
				local atk=math.ceil(og:GetSum(Card.GetTextAttack)/2)
				-- 给与对方玩家相当于被破坏怪兽原本攻击力合计数值一半的伤害
				Duel.Damage(1-tp,atk,REASON_EFFECT)
			end
		end
	end
end
