--究極伝導恐獣
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把2只恐龙族怪兽除外的场合可以特殊召唤。
-- ①：1回合1次，自己·对方的主要阶段才能发动。选自己的手卡·场上1只怪兽破坏，对方场上的表侧表示怪兽全部变成里侧守备表示。
-- ②：这张卡可以向对方怪兽全部各作1次攻击。
-- ③：这张卡向守备表示怪兽攻击的伤害步骤开始时才能发动。给与对方1000伤害，那只守备表示怪兽送去墓地。
function c18940556.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把2只恐龙族怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18940556.sprcon)
	e1:SetTarget(c18940556.sprtg)
	e1:SetOperation(c18940556.sprop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己·对方的主要阶段才能发动。选自己的手卡·场上1只怪兽破坏，对方场上的表侧表示怪兽全部变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18940556,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c18940556.descon)
	e2:SetTarget(c18940556.destg)
	e2:SetOperation(c18940556.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡可以向对方怪兽全部各作1次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡向守备表示怪兽攻击的伤害步骤开始时才能发动。给与对方1000伤害，那只守备表示怪兽送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18940556,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetTarget(c18940556.tgtg)
	e4:SetOperation(c18940556.tgop)
	c:RegisterEffect(e4)
end
-- 过滤墓地中满足条件的卡：必须是恐龙族怪兽，并且可以作为代价除外。
function c18940556.sprfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则条件：自己场上主要怪兽区有空位，且自己墓地存在至少2只恐龙族怪兽可作为代价除外。
function c18940556.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否还有可用的主要怪兽区空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只满足除外条件的恐龙族怪兽。
		and Duel.IsExistingMatchingCard(c18940556.sprfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤规则处理时，从自己墓地的恐龙族怪兽中选择2张作为除外代价；若成功选择则保存该组并返回true。
function c18940556.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足除外条件的恐龙族怪兽，形成候选组。
	local g=Duel.GetMatchingGroup(c18940556.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则实际执行：取出之前保存的2张恐龙族怪兽并将其除外，完成特殊召唤手续。
function c18940556.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以表侧表示除外，原因为特殊召唤。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- ①效果的发动条件：当前阶段为自己或对方的主要阶段。
function c18940556.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤对方场上的怪兽：必须是表侧表示，并且可以变成里侧守备表示。
function c18940556.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的发动条件检查：自己手牌或场上有1只怪兽可被破坏，且对方场上有1只表侧表示且可变为里侧守备表示的怪兽。
function c18940556.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌或场上是否存在至少1只怪兽，用于作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
		-- 检查对方场上是否存在至少1只表侧表示且可变为里侧守备表示的怪兽。
		and Duel.IsExistingMatchingCard(c18940556.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足表侧表示且可变为里侧守备表示的怪兽。
	local g=Duel.GetMatchingGroup(c18940556.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 将本次连锁的操作信息登记为：破坏自己手牌或场上的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 将本次连锁的操作信息登记为：改变对方场上满足条件的表侧怪兽的表示形式，数量为获取到的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ①效果处理：先选择并破坏自己手牌或场上的1只怪兽，若破坏成功，则将对方场上所有满足条件的表侧表示怪兽变成里侧守备表示。
function c18940556.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己手牌或场上的怪兽中选择1只作为破坏对象。
	local g1=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,TYPE_MONSTER)
	-- 若成功选择到怪兽并实际破坏成功，则继续处理后续翻转效果。
	if g1:GetCount()>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		-- 获取对方场上所有表侧表示且可变为里侧守备的怪兽。
		local g2=Duel.GetMatchingGroup(c18940556.posfilter,tp,0,LOCATION_MZONE,nil)
		if g2:GetCount()>0 then
			-- 将这些怪兽全部变成里侧守备表示。
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- ③效果的发动条件：本卡进行攻击，且攻击对象为守备表示怪兽；同时将伤害和送墓信息登记。
function c18940556.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击的对象。
	local d=Duel.GetAttackTarget()
	-- 检查攻击者是否为这张卡，且攻击目标存在并处于守备表示。
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and d and d:IsDefensePos() end
	-- 登记给与对方1000点伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	-- 登记将攻击对象送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,d,1,0,0)
end
-- ③效果处理：给与对方1000点伤害，若伤害成功且攻击目标仍与战斗相关并保持守备表示，则将其送去墓地。
function c18940556.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与对方1000点效果伤害，并判断是否造成伤害成功。
	if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 then
		-- 再次获取当前攻击目标。
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() and d:IsDefensePos() then
			-- 将攻击目标怪兽送去墓地。
			Duel.SendtoGrave(d,REASON_EFFECT)
		end
	end
end
