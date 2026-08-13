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
	-- 为这张卡添加灵摆怪兽的基本属性，使其可以作为灵摆卡从手牌发动到灵摆区、进行灵摆召唤，并支持灵摆区域的规则处理。
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
	-- ①：把这张卡以外的自己场上1只怪兽解放才能发动。从以下效果选1个直到回合结束时适用。●这张卡可以直接攻击。●对方不能把魔法与陷阱区域的卡的效果发动。●对方不能把手卡·墓地的卡的效果发动。
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
	-- ③：这张卡不会被战斗破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ③：这张卡的战斗发生的对自己的战斗伤害变成0
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
-- 伤害减免效果的发动条件：检查效果持有者玩家是否尚未使用过本回合的灵摆效果①（即标志40227329数量为0），只有未使用过时才允许将效果伤害变成0。
function c40227329.damcon(e)
	-- 判断玩家是否没有本回合使用过①效果的标志（40227329），标志数量为0则条件为真，保证一回合一次。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),40227329)==0
end
-- 效果伤害改变处理：若本次伤害来自效果伤害（REASON_EFFECT）且这张卡自身还没有本回合使用过的标志（c:GetFlagEffect(40227329)==0），则给持有者玩家注册结束阶段重置的标志，并将伤害值改为0；否则保持原伤害。
function c40227329.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_EFFECT)~=0 and c:GetFlagEffect(40227329)==0 then
		-- 为持有者玩家注册标志40227329，持续到本次回合结束阶段，用于标记本回合已经使用过灵摆效果①（伤害变为0）一次。
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),40227329,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 无解放召唤的适用条件：当c为nil时返回true允许系统查询规则；否则要求所需解放数为0（不需要解放）且控制者主要怪兽区有空位，才能通过此效果免除5星以上DD怪兽召唤的解放。
function c40227329.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查召唤所需解放数为0且怪兽区有空位，只有这两个条件同时满足才能无解放召唤。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 指定可通过该召唤规则召唤的怪兽：必须是5星以上且属于「DD」字段（setcode 0xaf）的怪兽，满足条件才适用不用解放的规则。
function c40227329.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0xaf)
end
-- 效果发动代价处理：chk==0时检查是否存在除这张卡以外可解放的怪兽；然后让玩家选择1只自己场上的其他怪兽，将其解放作为发动代价。
function c40227329.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，确认自己场上存在除这张卡以外的至少1只可解放的怪兽，若存在则效果可以发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 从自己场上选择1只除这张卡以外的可解放怪兽，作为发动效果将要解放的代价卡。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 将选择的怪兽解放（REASON_COST），支付发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果发动条件：chk==0时计算三个可选效果中是否有至少一个当前可以使用，只要有一个可用即可发动（并作为效果发动的合法性条件）。
function c40227329.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 选项1可用性：这张卡尚未获得直接攻击效果，且回合玩家可以进入战斗阶段（保证直击效果有意义）。
		local b1=not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
		-- 选项2可用性：本回合尚未选择过‘对方不能发动魔法与陷阱区域卡的效果’这一选项（通过标志40227330为0判断），避免重复选择。
		local b2=Duel.GetFlagEffect(tp,40227330)==0
		-- 选项3可用性：本回合尚未选择过‘对方不能发动手卡·墓地的卡的效果’这一选项（通过标志40227331为0判断），避免重复选择。
		local b3=Duel.GetFlagEffect(tp,40227331)==0
		return b1 or b2 or b3
	end
end
-- 效果处理：根据玩家选择的选项（op=1/2/3）分别给这张卡赋予直接攻击能力，或给对手附加不能发动魔陷区/手卡·墓地卡效果的限制，并设置对应标志记录已选效果。
function c40227329.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新确认选项1可用性：这张卡尚无直接攻击效果且可进入战斗阶段，保证选项1可选。
	local b1=not c:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsAbleToEnterBP()
	-- 处理时重新确认选项2可用性：标志40227330为0，即本回合尚未选择过选项2。
	local b2=Duel.GetFlagEffect(tp,40227330)==0
	-- 处理时重新确认选项3可用性：标志40227331为0，即本回合尚未选择过选项3。
	local b3=Duel.GetFlagEffect(tp,40227331)==0
	-- 调用辅助选择函数，向玩家展示三个可用的选项（由b1/b2/b3控制是否可选），并获取玩家选择的选项编号op。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(40227329,0)},  --"这张卡可以直接攻击"
		{b2,aux.Stringid(40227329,1)},  --"对方不能把魔法与陷阱区域的卡的效果发动"
		{b3,aux.Stringid(40227329,2)})  --"对方不能把手卡·墓地的卡的效果发动"
	if op==1 then
		-- ●这张卡可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	elseif op==2 then
		-- ●对方不能把魔法与陷阱区域的卡的效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(c40227329.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将‘对方不能发动魔法与陷阱区域卡的效果’的永续效果注册到当前玩家tp，使其对对方玩家生效，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
		-- 为当前玩家注册标志40227330，持续到回合结束，标记本回合已选择过‘禁魔陷区效果’的选项。
		Duel.RegisterFlagEffect(tp,40227330,RESET_PHASE+PHASE_END,0,1)
	elseif op==3 then
		-- ●对方不能把手卡·墓地的卡的效果发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(c40227329.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将‘对方不能发动手卡·墓地的卡的效果’的永续效果注册到当前玩家tp，使其对对方玩家生效，持续到回合结束。
		Duel.RegisterEffect(e3,tp)
		-- 为当前玩家注册标志40227331，持续到回合结束，标记本回合已选择过‘禁手卡·墓地效果’的选项。
		Duel.RegisterFlagEffect(tp,40227331,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断某效果的发动位置是否在魔法与陷阱区域（含灵摆区），若是则不能发动；用于实现‘对方不能把魔法与陷阱区域的卡的效果发动’。
function c40227329.aclimit1(e,re,tp)
	return re:GetActivateLocation()==LOCATION_SZONE
end
-- 判断某效果的发动位置是否在手卡或墓地，若是则不能发动；用于实现‘对方不能把手卡·墓地的卡的效果发动’。
function c40227329.aclimit2(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE or re:GetActivateLocation()==LOCATION_HAND
end
-- 攻击力上升效果的发动条件：对方基本分在4000以下时，这张卡攻击宣言的时点才能发动。
function c40227329.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方（1-tp）当前基本分是否不超过4000，满足则攻击力上升效果可发动。
	return Duel.GetLP(1-tp)<=4000
end
-- 攻击力上升效果处理：获取对方当前基本分数值，给这张卡赋予等量的攻击力上升效果，持续到回合结束（若卡离场或无效则重置）。
function c40227329.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方当前基本分数值，作为攻击力上升的数值。
	local lp=Duel.GetLP(1-tp)
	-- 这张卡的攻击力直到回合结束时上升对方基本分数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(lp)
	c:RegisterEffect(e1)
end
