--黒魔術のバリア －ミラーフォース－
-- 效果：
-- ①：对方怪兽的攻击宣言时或者有要让场上的怪兽破坏的对方怪兽的效果发动时，若有着有「光之黄金柜」的卡名记述的怪兽在场上存在则能发动。对方场上的攻击表示怪兽全部破坏。自己场上有「黑魔术师」存在的场合，再给与对方破坏的怪兽数量×500伤害。这张卡的发动后，这个回合中，有「光之黄金柜」的卡名记述的自己场上的怪兽各有1次不会被战斗·效果破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含攻击宣言时发动和对方怪兽效果发动时发动的两个触发时点
function s.initial_effect(c)
	-- 将「光之黄金柜」和「黑魔术师」的卡片密码注册到该卡的关联卡片列表中
	aux.AddCodeList(c,79791878,46986414)
	-- ①：对方怪兽的攻击宣言时或者有要让场上的怪兽破坏的对方怪兽的效果发动时，若有着有「光之黄金柜」的卡名记述的怪兽在场上存在则能发动。对方场上的攻击表示怪兽全部破坏。自己场上有「黑魔术师」存在的场合，再给与对方破坏的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示存在、且卡名记述有「光之黄金柜」的怪兽
function s.cfilter1(c)
	-- 检查卡片是否表侧表示存在且其文本中记述了「光之黄金柜」的卡名
	return aux.IsCodeListed(c,79791878) and c:IsFaceup()
end
-- 攻击宣言时发动的条件判定：必须是对方回合（对方怪兽攻击宣言时）
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤条件：处于攻击表示的怪兽
function s.filter(c)
	return c:IsAttackPos()
end
-- 效果发动时的目标选择与检测函数，确认对方场上有攻击表示怪兽且场上有记述「光之黄金柜」的怪兽存在，并设置破坏操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：对方场上存在至少1只攻击表示怪兽，且场上存在至少1只记述有「光之黄金柜」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤条件：自己场上表侧表示存在的「黑魔术师」
function s.cfilter2(c)
	return c:IsCode(46986414) and c:IsFaceup()
end
-- 效果处理的核心函数，执行破坏对方攻击表示怪兽、给予伤害（若有黑魔术师），并为记述「光之黄金柜」的怪兽适用破坏抗性
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的攻击表示怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 破坏所有符合条件的怪兽，并获取实际被破坏的怪兽数量
		local ct=Duel.Destroy(g,REASON_EFFECT)
		-- 检查自己场上是否存在表侧表示的「黑魔术师」
		if Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) then
			-- 中断当前效果处理，使后续的伤害处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 给予对方被破坏怪兽数量×500的伤害
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，这个回合中，有「光之黄金柜」的卡名记述的自己场上的怪兽各有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.efftg)
		e1:SetValue(s.indct)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局注册该回合内适用的破坏抗性效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏抗性效果的影响对象过滤函数
function s.efftg(e,c)
	-- 检查怪兽是否记述了「光之黄金柜」的卡名
	return aux.IsCodeListed(c,79791878)
end
-- 设置抗性次数：因战斗或效果破坏时，各有1次不会被破坏
function s.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 过滤条件：场上的怪兽卡（用于检测对方效果是否包含破坏场上怪兽的效果）
function s.cfilter3(c)
	return c:IsOnField() and c:IsType(TYPE_MONSTER)
end
-- 对方怪兽效果发动时的发动条件判定：检测对方发动的怪兽效果是否包含破坏场上怪兽的效果
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep then return false end
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	-- 获取对方连锁中发动的效果的破坏操作信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(s.cfilter3,nil)-tg:GetCount()>0
end
