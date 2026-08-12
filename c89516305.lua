--No.87 雪月花美神クイーン・オブ・ナイツ
-- 效果：
-- 8星怪兽×3
-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。这个效果在对方回合也能发动。
-- ●以对方场上盖放的1张魔法·陷阱卡为对象才能发动。只要这张卡在怪兽区域存在，那张卡不能发动。
-- ●以场上1只植物族怪兽为对象才能发动。那只植物族怪兽变成里侧守备表示。
-- ●以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升300。
function c89516305.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：需要3只8星怪兽。
	aux.AddXyzProcedure(c,nil,8,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。这个效果在对方回合也能发动。●以对方场上盖放的1张魔法·陷阱卡为对象才能发动。只要这张卡在怪兽区域存在，那张卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89516305,0))  --"盖放的1张魔法·陷阱卡不能发动"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(c89516305.cost)
	e1:SetTarget(c89516305.sttg)
	e1:SetOperation(c89516305.stop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。这个效果在对方回合也能发动。●以场上1只植物族怪兽为对象才能发动。那只植物族怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89516305,1))  --"1只植物族怪兽变成里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c89516305.cost)
	e2:SetTarget(c89516305.settg)
	e2:SetOperation(c89516305.setop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，可以把这张卡1个超量素材取除，从以下效果选择1个发动。这个效果在对方回合也能发动。●以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89516305,2))  --"1只怪兽上升攻击力"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：在伤害步骤中，只能在伤害计算前发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c89516305.cost)
	e3:SetTarget(c89516305.atktg)
	e3:SetOperation(c89516305.atkop)
	c:RegisterEffect(e3)
end
-- 设定该怪兽的“No.”编号为87。
aux.xyz_number[89516305]=87
-- 定义效果发动的代价（Cost）函数：检查并取除这张卡的1个超量素材。
function c89516305.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示当前选择发动的是哪一个分支效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果1（封锁魔陷）的靶向（Target）函数：选择对方场上盖放的一张魔法·陷阱卡。
function c89516305.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 检查对方魔陷区是否存在可以作为对象的里侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 提示玩家选择里侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 玩家选择对方场上1张里侧表示的魔法·陷阱卡作为效果对象。
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
end
-- 定义效果1（封锁魔陷）的操作（Operation）函数：使作为对象的卡不能发动。
function c89516305.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果处理中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 只要这张卡在怪兽区域存在，那张卡不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_TARGET)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：筛选场上表侧表示、属于植物族且可以变成里侧表示的怪兽。
function c89516305.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsCanTurnSet()
end
-- 定义效果2（变成里侧）的靶向（Target）函数：选择场上1只表侧表示的植物族怪兽。
function c89516305.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c89516305.setfilter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c89516305.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择场上1只表侧表示的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c89516305.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：包含改变表示形式的操作，对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 定义效果2（变成里侧）的操作（Operation）函数：将作为对象的植物族怪兽变成里侧守备表示。
function c89516305.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 定义效果3（上升攻击力）的靶向（Target）函数：选择场上1只表侧表示的怪兽。
function c89516305.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示的怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果3（上升攻击力）的操作（Operation）函数：使作为对象的怪兽攻击力上升300。
function c89516305.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
