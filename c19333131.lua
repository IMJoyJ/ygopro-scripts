--No.12 機甲忍者クリムゾン・シャドー
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这个回合，自己场上的「忍者」怪兽不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c19333131.initial_effect(c)
	-- 为卡片添加等级为5、需要2只怪兽进行XYZ召唤的手续
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
-- 设置该卡的XYZ编号为12
aux.xyz_number[19333131]=12
-- 费用处理函数：检查并移除1个超量素材作为发动代价
function c19333131.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的处理函数：为我方场上「忍者」怪兽赋予战斗破坏耐性与效果破坏耐性
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
	-- 将效果e1注册给玩家tp，使其生效
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将效果e2注册给玩家tp，使其生效
	Duel.RegisterEffect(e2,tp)
end
-- 目标过滤函数：筛选场上表侧表示的「忍者」怪兽
function c19333131.etarget(e,c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
