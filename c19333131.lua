--No.12 機甲忍者クリムゾン・シャドー
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，自己场上的「忍者」怪兽不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c19333131.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：将2只5星怪兽叠放作为超量素材进行XYZ召唤（阶级5）。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，自己场上的「忍者」怪兽不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19333131,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c19333131.cost)
	e1:SetOperation(c19333131.operation)
	c:RegisterEffect(e1)
end
-- 将该卡登记为No.12，使其适用No.卡的共通规则（如No.怪兽只能被No.怪兽战斗破坏）。
aux.xyz_number[19333131]=12
-- 代价函数：在发动时检测并移除这张卡的1个超量素材作为发动代价；若可支付则实际执行移除动作。
function c19333131.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：发动成功后，给己方场上的表侧表示「忍者」怪兽赋予这个回合内不会被战斗破坏和效果破坏的耐性，持续到回合结束。
function c19333131.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己场上的「忍者」怪兽不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c19333131.etarget)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不会被战斗破坏”的字段效果注册给当前玩家，使其适用于己方场上符合条件的「忍者」怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将“不会被效果破坏”的字段效果注册给当前玩家，使其适用于己方场上符合条件的「忍者」怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 对象筛选函数：判定场上的怪兽是否为表侧表示且属于「忍者」字段（0x2b），以决定哪些怪兽获得破坏抗性。
function c19333131.etarget(e,c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
