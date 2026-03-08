--メガリス・ノートラ・プルーラ
-- 效果：
-- 「巨石遗物」卡降临
-- 这张卡若非以只使用仪式怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这个回合，对方不能对应自己的「巨石遗物」仪式怪兽的效果的发动把效果发动。
-- ②：对方把卡的效果发动时才能发动。那个发动无效并破坏。这个效果把以场上的卡为对象的效果的发动无效的场合，可以再把对方场上1只怪兽解放。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括特殊召唤限制、手牌效果和场上的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用仪式怪兽来作的仪式召唤则不能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过仪式召唤方式特殊召唤的条件
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。这个回合，对方不能对应自己的「巨石遗物」仪式怪兽的效果的发动把效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反制连锁"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.prcost)
	e1:SetOperation(s.prop)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时才能发动。那个发动无效并破坏。这个效果把以场上的卡为对象的效果的发动无效的场合，可以再把对方场上1只怪兽解放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为仪式怪兽
function s.mat_filter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER)
end
-- 效果发动时的费用，确认手牌中的卡是否已公开
function s.prcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 将效果发动时的处理注册为持续效果，用于限制对方在本回合对「巨石遗物」仪式怪兽效果的连锁
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果发动时的处理注册为持续效果，用于限制对方在本回合对「巨石遗物」仪式怪兽效果的连锁
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 当有连锁发动时，检查是否为己方的「巨石遗物」仪式怪兽效果，若是则设置连锁限制
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsAllTypes(TYPE_MONSTER+TYPE_RITUAL) and rc:IsSetCard(0x138) and re:IsActiveType(TYPE_MONSTER) and ep==tp then
		-- 设置连锁限制函数，使对方不能连锁己方的「巨石遗物」仪式怪兽效果
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制函数，返回值为true表示允许连锁
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 判断是否可以发动效果，检查是否为对方发动且该卡未在战斗中被破坏
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前连锁的目标卡片组
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
			e:SetLabel(1)
		else
			e:SetLabel(0)
		end
	else
		e:SetLabel(0)
	end
	-- 检查当前连锁是否可以被无效
	return Duel.IsChainNegatable(ev)
end
-- 设置效果的目标信息，包括使发动无效和破坏
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的类别信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏目标的类别信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理，包括无效发动、破坏目标、判断是否可以解放对方怪兽
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁发动无效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev)
		-- 破坏发动效果的卡片
		and Duel.Destroy(eg,REASON_EFFECT)~=0
		and e:GetLabel()==1
		-- 检查对方场上是否存在可解放的怪兽
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否选择解放怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽解放？"
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择对方场上的1只可解放的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 显示所选怪兽被解放的动画效果
			Duel.HintSelection(g)
			-- 将所选怪兽解放
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
