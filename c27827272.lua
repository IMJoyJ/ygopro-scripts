--魔霧雨
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以自己的怪兽区域1只「恶魔召唤」或者雷族怪兽为对象才能发动。持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏。
function c27827272.initial_effect(c)
	-- 效果原文内容：这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27827272.cost)
	e1:SetTarget(c27827272.target)
	e1:SetOperation(c27827272.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查当前阶段是否为主要阶段1，是则发动效果
function c27827272.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否为检查阶段，若为则返回当前阶段是否为主要阶段1
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 效果原文内容：①：以自己的怪兽区域1只「恶魔召唤」或者雷族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果注册给玩家，使其在当前回合无法进入战斗阶段
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面操作：过滤满足条件的怪兽（为「恶魔召唤」或雷族怪兽）
function c27827272.filter(c,tp)
	return c:IsFaceup() and (c:IsCode(70781052) or c:IsRace(RACE_THUNDER))
		-- 规则层面操作：检查是否存在满足条件的对方怪兽（守备力低于目标怪兽攻击力）
		and Duel.IsExistingMatchingCard(c27827272.filter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 规则层面操作：过滤满足条件的对方怪兽（守备力低于指定攻击力）
function c27827272.filter2(c,atk)
	return c:IsFaceup() and c:IsDefenseBelow(atk)
end
-- 效果原文内容：持有那只怪兽的攻击力以下的守备力的对方场上的怪兽全部破坏。
function c27827272.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27827272.filter(chkc,tp) end
	-- 规则层面操作：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c27827272.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 规则层面操作：提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 规则层面操作：选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c27827272.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 规则层面操作：获取所有满足条件的对方怪兽（守备力低于目标怪兽攻击力）
	local dg=Duel.GetMatchingGroup(c27827272.filter2,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 规则层面操作：设置连锁操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 规则层面操作：处理效果，破坏符合条件的对方怪兽
function c27827272.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面操作：获取所有满足条件的对方怪兽（守备力低于目标怪兽攻击力）
		local dg=Duel.GetMatchingGroup(c27827272.filter2,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 规则层面操作：以效果原因破坏符合条件的对方怪兽
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
