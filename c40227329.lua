--GO－DDD神零王ゼロゴッド・レイジ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：这张卡在灵摆区域存在，自己受到效果伤害的场合，那次伤害变成0。
-- ②：只要这张卡在灵摆区域存在，自己在5星以上的「DD」怪兽召唤的场合需要的解放可以不用。
-- 【怪兽效果】
-- ①：把这张卡以外的自己场上1只怪兽解放才能发动。从以下效果选1个直到回合结束时适用。
-- ●这张卡可以直接攻击。
-- ●对方不能把魔法与陷阱区域的卡的效果发动。
-- ●对方不能把手卡·墓地的卡的效果发动。
-- ②：对方基本分是4000以下的场合，这张卡的攻击宣言时才能发动。这张卡的攻击力直到回合结束时上升对方基本分数值。
-- ③：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
function c40227329.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡在灵摆区域存在，自己受到效果伤害的场合，那次伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(c40227329.damcon)
	e1:SetValue(c40227329.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
	-- ①：把这张卡以外的自己场上1只怪兽解放才能发动。从以下效果选1个直到回合结束时适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40227329,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c40227329.effcost)
	e3:SetTarget(c40227329.efftg)
	e3:SetOperation(c40227329.effop)
	c:RegisterEffect(e3)
	-- ②：对方基本分是4000以下的场合，这张卡的攻击宣言时才能发动。这张卡的攻击力直到回合结束时上升对方基本分数值。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c40227329.atkcon)
	e4:SetOperation(c40227329.atkop)
	c:RegisterEffect(e4)
	-- ③：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ③：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	-- ②：只要这张卡在灵摆区域存在，自己在5星以上的「DD」怪兽召唤的场合需要的解放可以不用。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(40227329,4))  --"使用「GO-DDD 神零王 零神·零儿」的效果不用解放"
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetTargetRange(LOCATION_HAND,0)
	e7:SetCode(EFFECT_SUMMON_PROC)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCountLimit(1,40227329)
	e7:SetCondition(c40227329.ntcon)
	e7:SetTarget(c40227329.nttg)
	c:RegisterEffect(e7)
end
-- 判断是否已使用过①灵摆效果，若未使用则返回true
function c40227329.damcon(e)
	-- 判断玩家是否已使用过①灵摆效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),40227329)==0
end
-- 当受到效果伤害时，若未使用过①灵摆效果则将伤害设为0并记录使用
function c40227329.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT)~=0 and c:GetFlagEffect(40227329)==0 then
		-- 记录玩家已使用过①灵摆效果，防止重复使用
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),40227329,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 判断召唤条件是否满足，若满足则允许召唤5星以上的DD怪兽且无需解放
function c40227329.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤时是否满足召唤条件，即召唤的怪兽等级≥5且为DD卡组
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断目标怪兽是否为5星以上且为DD卡组
function c40227329.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0xaf)
end
-- 检查是否可以解放1只怪兽作为发动cost
function c40227329.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放1只怪兽作为发动cost
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 选择1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 将选中的怪兽解放作为发动cost
	Duel.Release(g,REASON_COST)
end
-- 判断是否可以发动①效果，即是否满足任意一个选项条件
function c40227329.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 判断是否可以发动“这张卡可以直接攻击”效果
		local b1=not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
		-- 判断是否可以发动“对方不能把魔法与陷阱区域的卡的效果发动”效果
		local b2=Duel.GetFlagEffect(tp,40227330)==0
		-- 判断是否可以发动“对方不能把手卡·墓地的卡的效果发动”效果
		local b3=Duel.GetFlagEffect(tp,40227331)==0
		return b1 or b2 or b3
	end
end
-- 执行①效果的发动操作，根据选择的选项施加对应效果
function c40227329.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以发动“这张卡可以直接攻击”效果
	local b1=not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
	-- 判断是否可以发动“对方不能把魔法与陷阱区域的卡的效果发动”效果
	local b2=Duel.GetFlagEffect(tp,40227330)==0
	-- 判断是否可以发动“对方不能把手卡·墓地的卡的效果发动”效果
	local b3=Duel.GetFlagEffect(tp,40227331)==0
	-- 让玩家从选项中选择一个效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(40227329,0)},  --"这张卡可以直接攻击"
		{b2,aux.Stringid(40227329,1)},  --"对方不能把魔法与陷阱区域的卡的效果发动"
		{b3,aux.Stringid(40227329,2)})  --"对方不能把手卡·墓地的卡的效果发动"
	if op==1 then
		-- 使这张卡获得直接攻击效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	elseif op==2 then
		-- 使对方不能发动魔法与陷阱区域的卡的效果，并记录使用
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(c40227329.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使对方不能发动魔法与陷阱区域的卡的效果
		Duel.RegisterEffect(e2,tp)
		-- 记录玩家已使用过②灵摆效果，防止重复使用
		Duel.RegisterFlagEffect(tp,40227330,RESET_PHASE+PHASE_END,0,1)
	elseif op==3 then
		-- 使对方不能发动手卡或墓地的卡的效果，并记录使用
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(c40227329.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使对方不能发动手卡或墓地的卡的效果
		Duel.RegisterEffect(e3,tp)
		-- 记录玩家已使用过③灵摆效果，防止重复使用
		Duel.RegisterFlagEffect(tp,40227331,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 限制对方不能发动魔法区域的卡的效果
function c40227329.aclimit1(e,re,tp)
	return re:GetActivateLocation()==LOCATION_SZONE
end
-- 限制对方不能发动手卡或墓地的卡的效果
function c40227329.aclimit2(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE or re:GetActivateLocation()==LOCATION_HAND
end
-- 判断对方基本分是否≤4000
function c40227329.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方基本分是否≤4000
	return Duel.GetLP(1-tp)<=4000
end
-- 将这张卡的攻击力提升至对方基本分数值
function c40227329.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方的基本分
	local lp=Duel.GetLP(1-tp)
	-- 使这张卡的攻击力提升至对方基本分数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(lp)
	c:RegisterEffect(e1)
end
