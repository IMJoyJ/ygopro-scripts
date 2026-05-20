--あないみじや玉の緒ふたつ
-- 效果：
-- 从额外卡组特殊召唤的自己场上的怪兽才能装备。
-- ①：比装备怪兽攻击力高的怪兽由对方从额外卡组特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽以及装备怪兽破坏，自己受到破坏的怪兽的原本攻击力合计数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
local s,id,o=GetID()
-- 初始化函数，注册装备魔法卡的发动、装备限制以及被特殊召唤时的诱发效果
function s.initial_effect(c)
	-- 从额外卡组特殊召唤的自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 从额外卡组特殊召唤的自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- 注册合并的特殊召唤成功延迟事件，用于检测对方从额外卡组特殊召唤怪兽的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ①：比装备怪兽攻击力高的怪兽由对方从额外卡组特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽以及装备怪兽破坏，自己受到破坏的怪兽的原本攻击力合计数值的伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 装备限制判定，限制只能装备给从额外卡组特殊召唤的自己场上的怪兽
function s.eqlimit(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsControler(e:GetHandlerPlayer())
end
-- 过滤自己场上表侧表示且从额外卡组特殊召唤的怪兽
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
		and c:IsControler(tp)
end
-- 装备卡发动时的目标选择与合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp) end
	-- 检查场上是否存在可以作为装备对象的合法怪兽
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只满足装备条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置当前连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡发动处理的执行函数，将此卡装备给选择的对象
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsControler(tp) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 过滤满足破坏条件的对象（对方从额外卡组特殊召唤的、表侧表示且攻击力比装备怪兽高的怪兽）
function s.desfilter(c,tp,e,ec)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
		and c:IsAttackAbove(ec:GetAttack()+1)
end
-- ①效果的发动条件判定，检查是否有满足条件的对方怪兽被特殊召唤
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsExists(s.desfilter,1,nil,tp,e,ec)
end
-- ①效果的发动准备与目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local g=eg:Filter(s.desfilter,nil,tp,e,ec)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 当只有1只满足条件的怪兽被特殊召唤时，直接将其设为效果的对象
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINTMSG_DESTROY,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从特殊召唤的怪兽中选择1只作为破坏的对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	local dg=sg:Clone()
	dg:AddCard(ec)
	-- 设置当前连锁的操作信息为破坏这2张卡（目标怪兽和装备怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,0,0)
	if sg:GetFirst():IsFaceup() and math.max(0,sg:GetFirst():GetTextAttack())>0 then
		-- 设置当前连锁的操作信息为双方受到伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
	end
end
-- ①效果的实际处理函数，执行破坏、计算原本攻击力、对自己造成伤害以及对对方造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 获取作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(ec,tc)
	-- 判定对象怪兽是否仍存在，并尝试破坏目标怪兽以及装备怪兽
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取本次操作中实际被破坏的卡片组
		local sg=Duel.GetOperatedGroup()
		local atk=0
		-- 遍历实际被破坏的卡片，用于累加它们的原本攻击力
		for dc in aux.Next(sg) do
			atk=atk+math.max(0,dc:GetTextAttack())
		end
		if atk>0 then
			-- 给与自己被破坏怪兽的原本攻击力合计数值的伤害，并获取实际受到的伤害值
			local val=Duel.Damage(tp,atk,REASON_EFFECT)
			-- 检查自己是否实际受到了伤害，且自己的生命值仍大于0
			if val>0 and Duel.GetLP(tp)>0 then
				-- 中断当前效果处理，使后续的伤害处理与之前的伤害处理不视为同时进行
				Duel.BreakEffect()
				-- 给与对方和自己受到的伤害相同数值的伤害
				Duel.Damage(1-tp,val,REASON_EFFECT)
			end
		end
	end
end
