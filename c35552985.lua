--刻まれし魔の讃聖
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有恶魔族·光属性怪兽的场合才能发动。在自己场上把1只「刻魔衍生物」（恶魔族·光·1星·攻/守0）特殊召唤。这个回合，自己不用恶魔族怪兽不能攻击宣言。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「刻魔」怪兽被对方的效果破坏的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果：创建并注册①的发动效果（特召刻魔衍生物）和②的触发效果（墓地盖放），分别设置描述、分类、类型、发动时机、次数限制、条件/目标/处理函数。
function s.initial_effect(c)
	-- ①：自己场上的表侧表示怪兽不存在的场合或者只有恶魔族·光属性怪兽的场合才能发动。在自己场上把1只「刻魔衍生物」（恶魔族·光·1星·攻/守0）特殊召唤。这个回合，自己不用恶魔族怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「刻魔」怪兽被对方的效果破坏的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义①的发动条件过滤器：返回true表示场上存在表侧表示且不是恶魔族·光属性的怪兽，用于阻断①的发动。
function s.cfilter(c)
	return not (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsFaceup()
end
-- ①的发动条件判定：自己场上不存在表侧表示的非恶魔族·光属性怪兽（即没有表侧怪兽或只有恶魔族·光属性怪兽）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且非恶魔族·光属性的怪兽；不存在则条件满足。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①发动时进行合法性检查：自己的主要怪兽区有空位，且自己能够特殊召唤「刻魔衍生物」（恶魔族·光·1星·攻/守0）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位（大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查自己是否能够将「刻魔衍生物」（恶魔族·光·1星·攻/守0）以表侧表示特殊召唤到场上。
		Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：本效果将产生1只衍生物，供连锁判定和效果提示使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果将进行1次特殊召唤（对象在效果处理时确定，targets为nil，控制者为tp）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ①效果处理：若仍有空位且能特招token，则创建「刻魔衍生物」并表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己主要怪兽区仍有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 处理时再次确认自己仍然能够特殊召唤该token。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) then
		-- 创建「刻魔衍生物」（卡号为id+o，恶魔族·光·1星·攻/守0）的Token，控制者为tp。
		local token=Duel.CreateToken(tp,id+o)
		-- 将token以表侧攻击表示特殊召唤到tp场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不用恶魔族怪兽不能攻击宣言。②：这张卡在墓地存在的状态，自己场上的表侧表示的「刻魔」怪兽被对方的效果破坏的场合才能发动。这张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将「不能攻击宣言」的永续效果注册到场上，影响tp方的主要怪兽区，直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制的对象判定：非恶魔族怪兽不能进行攻击宣言。
function s.atktg(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- ②的破坏对象过滤器：被破坏的怪兽必须是tp之前控制、之前位于主要怪兽区、表侧表示、且是「刻魔」字段怪兽（setcode 0x1b0）。
function s.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(0x1b0)
end
-- ②的发动条件：对方效果（rp==1-tp）破坏了自己场上的表侧表示「刻魔」怪兽，且被破坏的怪兽中不包含这张卡自身（e:GetHandler()排除）。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.cfilter2,1,e:GetHandler(),tp)
end
-- ②发动时检查：这张卡是否能够盖放到魔法陷阱区；若能则设置操作信息为从墓地离开。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：本效果将把墓地的这张卡盖放到场上，涉及墓地移动（CATEGORY_LEAVE_GRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认卡片仍与效果关联（未被除外等导致关系重置）后，将其盖放到自己的魔法陷阱区。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
