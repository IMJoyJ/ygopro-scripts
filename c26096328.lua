--超弩級砲塔列車ジャガーノート・リーベ
-- 效果：
-- 11星怪兽×3
-- 「超重型炮塔列车 破天巨爱」1回合1次也能在自己场上的机械族·10阶的超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升2000。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的超量素材数量＋1次的攻击。
function c26096328.initial_effect(c)
	aux.AddXyzProcedure(c,nil,11,3,c26096328.ovfilter,aux.Stringid(26096328,0),3,c26096328.xyzop)  --"是否在机械族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力·守备力上升2000。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26096328,0))  --"是否在机械族超量怪兽上面重叠来超量召唤？"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26096328.atkcost)
	e1:SetOperation(c26096328.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的超量素材数量＋1次的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(c26096328.raval)
	c:RegisterEffect(e2)
end
-- 过滤选择可作为重叠素材的怪兽：必须是表侧表示、阶级10、机械族的超量怪兽，用于此卡在机械族·10阶超量怪兽上面重叠来超量召唤。
function c26096328.ovfilter(c)
	return c:IsFaceup() and c:GetRank()==10 and c:IsRace(RACE_MACHINE)
end
-- 超量召唤手续的追加操作：检查并登记“1回合1次”的限制，确保这种重叠超量召唤一回合只能使用一次。
function c26096328.xyzop(e,tp,chk)
	-- 检查当前玩家是否已经使用过这种特殊召唤方式（通过flag数量是否为0），从而实现“1回合1次”的限制。
	if chk==0 then return Duel.GetFlagEffect(tp,26096328)==0 end
	-- 为当前玩家注册一个直到结束阶段有效的誓约flag，记录本回合已经使用过这种重叠超量召唤方式。
	Duel.RegisterFlagEffect(tp,26096328,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的发动代价：先检查能否取除这张卡的1个超量素材，若能则实际取除1个超量素材作为发动代价。
function c26096328.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果处理：这张卡攻击力·守备力各上升2000；并给自己场上所有怪兽（除这张卡自身外）附加“不能攻击”的限制，直到回合结束。
function c26096328.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力·守备力上升2000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ATTACK)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c26096328.ftarget)
	e0:SetLabel(c:GetFieldID())
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“不能攻击”的场地限制效果实际注册到当前回合玩家，使该玩家场上的怪兽（除自身外）直到结束阶段都不能攻击。
	Duel.RegisterEffect(e0,tp)
end
-- 作为不能攻击效果的过滤函数：若怪兽的FieldID不等于效果记录的这张卡的FieldID，则该怪兽不能攻击；也就是只有这张卡自身可以攻击。
function c26096328.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 返回这张卡当前的超量素材数量，作为额外攻击次数；配合EFFECT_EXTRA_ATTACK_MONSTER使总攻击次数为超量素材数量＋1。
function c26096328.raval(e,c)
	return e:GetHandler():GetOverlayCount()
end
