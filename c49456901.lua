--CNo.104 仮面魔踏士アンブラル
-- 效果：
-- 5星怪兽×4
-- ①：这张卡特殊召唤成功时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：这张卡有「No.104 假面魔蹈士 闪光」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，对方场上的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。那之后，可以把对方手卡随机选1张送去墓地，对方基本分变成一半。
function c49456901.initial_effect(c)
	-- 为卡片添加等级为5、需要4只怪兽作为素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,5,4)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49456901,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c49456901.destg)
	e1:SetOperation(c49456901.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「No.104 假面魔蹈士 闪光」在作为超量素材的场合，得到以下效果。●1回合1次，对方场上的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。那之后，可以把对方手卡随机选1张送去墓地，对方基本分变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49456901,1))  --"效果无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_HANDES)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c49456901.condition)
	e2:SetCost(c49456901.cost)
	e2:SetTarget(c49456901.target)
	e2:SetOperation(c49456901.operation)
	c:RegisterEffect(e2)
end
-- 设置该卡片的XYZ编号为104
aux.xyz_number[49456901]=104
-- 定义用于筛选魔法·陷阱卡的过滤器函数
function c49456901.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理效果的判断与目标选择：检查场上是否存在魔法或陷阱卡作为目标
function c49456901.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c49456901.desfilter(chkc) end
	-- 检查是否满足效果发动条件，即场上有魔法或陷阱卡可选
	if chk==0 then return Duel.IsExistingTarget(c49456901.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的魔法或陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c49456901.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，表示将要破坏选定的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的执行：若目标卡存在则将其破坏
function c49456901.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足发动条件：对方怪兽发动效果且该卡未在战斗中被破坏、对方玩家不为发动者、效果来自主要怪兽区、效果可被无效、该卡有No.104闪光作为超量素材
function c49456901.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判断连锁是否来自对方主要怪兽区、触发的是怪兽类型效果且该连锁可被无效
		and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,2061963)
end
-- 定义发动效果所需的费用：移除1个超量素材
function c49456901.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标信息，表示将要使对方效果无效
function c49456901.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 处理效果的执行：使对方效果无效，并可选择是否将对方手牌送去墓地及削减其LP
function c49456901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使对方效果无效且对方手牌存在
	if Duel.NegateActivation(ev) and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
		-- 询问玩家是否发动后续效果：将对方手牌随机送入墓地并削减其LP
		and Duel.SelectYesNo(tp,aux.Stringid(49456901,2)) then  --"是否要把对方手卡随机1张送去墓地，对方基本分变成一半？"
		-- 从对方手牌中随机选择1张卡
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(1-tp,1)
		-- 将选中的对方手牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 将对方基本分减半
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end
