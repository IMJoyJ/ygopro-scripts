--ゴッドアイズ・ファントム・ドラゴン
-- 效果：
-- ←0 【灵摆】 0→
-- ①：1回合1次，自己的龙族灵摆怪兽向对方怪兽攻击的伤害步骤结束时才能发动。那只自己怪兽可以继续攻击。这个效果发动的回合，自己不用那只怪兽不能攻击宣言。
-- 【怪兽效果】
-- 这张卡不能通常召唤。「神眼幻龙」1回合1次在把包含龙族灵摆怪兽的自己场上2只以上的全部怪兽解放的场合才能从手卡·额外卡组特殊召唤。
-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力直到回合结束时变成2倍。
-- ②：1回合1次，对方把魔法·陷阱卡的效果发动时，把自己场上1张魔法·陷阱卡送去墓地才能发动。那个发动无效。
function c70335319.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的龙族灵摆怪兽向对方怪兽攻击的伤害步骤结束时才能发动。那只自己怪兽可以继续攻击。这个效果发动的回合，自己不用那只怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c70335319.atcon)
	e1:SetCost(c70335319.atcost)
	e1:SetOperation(c70335319.atop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 「神眼幻龙」1回合1次在把包含龙族灵摆怪兽的自己场上2只以上的全部怪兽解放的场合才能从手卡·额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70335319,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,70335319+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c70335319.hspcon)
	e3:SetOperation(c70335319.hspop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e4)
	-- ①：1回合1次，这张卡和对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力直到回合结束时变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetCountLimit(1)
	e5:SetCondition(c70335319.atkcon)
	e5:SetOperation(c70335319.atkop)
	c:RegisterEffect(e5)
	-- ②：1回合1次，对方把魔法·陷阱卡的效果发动时，把自己场上1张魔法·陷阱卡送去墓地才能发动。那个发动无效。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(70335319,1))
	e6:SetCategory(CATEGORY_NEGATE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c70335319.negcon)
	e6:SetCost(c70335319.negcost)
	e6:SetTarget(c70335319.negtg)
	e6:SetOperation(c70335319.negop)
	c:RegisterEffect(e6)
	if not c70335319.global_check then
		c70335319.global_check=true
		c70335319[0]=0
		c70335319[1]=0
		-- 这个效果发动的回合，自己不用那只怪兽不能攻击宣言。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c70335319.check)
		-- 注册全局效果，用于在每个回合中记录和检测玩家进行攻击宣言的怪兽。
		Duel.RegisterEffect(ge1,0)
		-- 这个效果发动的回合，自己不用那只怪兽不能攻击宣言。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c70335319.clear)
		-- 注册全局效果，在每回合开始时重置攻击宣言的记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 攻击宣言时的全局检查函数，记录当前回合进行攻击宣言的怪兽，若有其他怪兽攻击则标记该玩家本回合已用其他怪兽进行过攻击。
function c70335319.check(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	if c70335319[2] and c70335319[2]~=at then
		c70335319[at:GetControler()]=1
		return
	end
	c70335319[2]=at
end
-- 回合开始时的重置函数，清空所有玩家的攻击宣言记录。
function c70335319.clear(e,tp,eg,ep,ev,re,r,rp)
	c70335319[0]=0
	c70335319[1]=0
	c70335319[2]=nil
end
-- 灵摆效果发动的条件检查：必须是自己的龙族灵摆怪兽向对方怪兽攻击的伤害步骤结束时，且该怪兽可以继续攻击。
function c70335319.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取刚刚进行战斗的己方攻击怪兽。
	local at=Duel.GetAttacker()
	-- 检查攻击怪兽是否由自己控制，且攻击对象（对方怪兽）不为空。
	return at:IsControler(tp) and Duel.GetAttackTarget()~=nil
		and at:IsRace(RACE_DRAGON) and at:IsType(TYPE_PENDULUM) and at:IsChainAttackable(0)
end
-- 灵摆效果的发动代价与限制：检查本回合是否没有用其他怪兽进行过攻击宣言，并给攻击怪兽添加标记，同时注册“本回合自己不能用其他怪兽进行攻击宣言”的限制。
function c70335319.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c70335319[tp]==0 end
	-- 获取当前进行攻击的怪兽，以便为其注册标记。
	local at=Duel.GetAttacker()
	at:RegisterFlagEffect(70335319,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 这个效果发动的回合，自己不用那只怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c70335319.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能进行攻击宣言”的全局限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制攻击宣言的过滤函数，使没有获得特定标记的怪兽无法进行攻击宣言。
function c70335319.atktg(e,c)
	return c:GetFlagEffect(70335319)==0
end
-- 灵摆效果的执行：使该怪兽可以继续攻击。
function c70335319.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击的怪兽可以再进行1次攻击。
	Duel.ChainAttack()
end
-- 过滤条件：龙族且是灵摆怪兽。
function c70335319.hspfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM)
end
-- 特殊召唤规则的条件检查：检查自己场上可解放的怪兽是否全部解放（至少2只），其中是否包含龙族灵摆怪兽，并检查额外卡组或手牌特殊召唤所需的怪兽区域空格是否足够。
function c70335319.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可用于特殊召唤解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	return g:GetCount()>=2 and g:FilterCount(Card.IsReleasable,nil,REASON_SPSUMMON)==g:GetCount()
		and g:IsExists(c70335319.hspfilter,1,nil)
		-- 若这张卡在额外卡组，检查解放这些怪兽后，额外怪兽区域或连接端是否有可用的空格。
		and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
			-- 若这张卡在手牌，检查解放这些怪兽后，主怪兽区域是否有可用的空格。
			or c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,g,tp)>0)
end
-- 特殊召唤规则的执行：解放自己场上的全部怪兽。
function c70335319.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取自己场上所有可解放的怪兽组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON)
	-- 解放选定的怪兽组。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 怪兽效果①的发动条件：这张卡与对方怪兽进行战斗。
function c70335319.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end
-- 怪兽效果①的执行：直到回合结束时，这张卡的攻击力变成2倍。
function c70335319.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 怪兽效果②的发动条件：这张卡未被战斗破坏，且对方发动了魔法·陷阱卡的效果，且该发动可以被无效。
function c70335319.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查发动效果的玩家是否为对方，且发动的效果是魔法或陷阱卡的效果，且该发动可以被无效。
		and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：自己场上的魔法·陷阱卡，且能作为代价送去墓地。
function c70335319.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 怪兽效果②的代价处理：选择自己场上1张魔法·陷阱卡送去墓地。
function c70335319.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c70335319.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1张满足条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c70335319.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 怪兽效果②的靶向处理：设置效果分类为“无效发动”。
function c70335319.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表明此效果的处理是将对方发动的魔法·陷阱卡效果无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 怪兽效果②的执行：使对方魔法·陷阱卡的发动无效。
function c70335319.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的发动。
	Duel.NegateActivation(ev)
end
