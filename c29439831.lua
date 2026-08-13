--瞳の魔女モルガナ
-- 效果：
-- 这个卡名在规则上也当作「魔瞳」卡使用。这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「魔瞳」魔法卡加入手卡。
-- ②：对方怪兽的攻击宣言时，从自己墓地把1张「魔瞳」魔法卡除外才能发动。那次攻击无效。
-- ③：自己的墓地·除外状态的「魔瞳」魔法卡是3种类以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
local s,id,o=GetID()
-- 该函数注册了这张卡的全部效果：①效果在召唤成功与特殊召唤成功时各注册一个实例（e1/e2，共1回合1次）用于从卡组检索「魔瞳」魔法卡；②效果注册为场上表侧表示时对方攻击宣言可发动，支付除外墓地「魔瞳」魔法卡的代价来无效攻击；③效果注册为起动效果，在墓地·除外状态「魔瞳」魔法卡达3种类以上时可将对方全场怪兽攻击力变为0。
function s.initial_effect(c)
	-- ①：这张卡召唤的场合才能发动。从卡组把1张「魔瞳」魔法卡加入手卡。（特殊召唤场合由e2复制此效果实现）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时，从自己墓地把1张「魔瞳」魔法卡除外才能发动。那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击无效"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ③：自己的墓地·除外状态的「魔瞳」魔法卡是3种类以上的场合才能发动。对方场上的全部怪兽的攻击力变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力变成0"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 检索过滤条件：从卡组中选出卡名视为「魔瞳」、类型为魔法卡且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①效果的发动条件和目标设定：在发动合法性检查时确认卡组存在符合检索条件的卡；合法后向对方提示发动了该效果，并登记操作信息为从卡组将1张卡加入手卡的检索处理。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：判断卡组中是否存在至少1张满足s.thfilter条件的「魔瞳」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家展示本效果的描述，提示对方本方发动了「检索魔瞳魔法卡」的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记连锁处理信息：本次效果将进行从卡组把1张卡加入手卡的操作，目标位置为卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：玩家从卡组选择1张符合条件的「魔瞳」魔法卡加入手卡，并将该卡展示给对手确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家从卡组中选择1张要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：从自己的卡组中选出1张满足s.thfilter条件的「魔瞳」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「魔瞳」魔法卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡片展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：当前进行攻击宣言的怪兽是对方场上的怪兽。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击宣言怪兽的控制者是否是对方（1-tp），若是则满足条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 代价筛选条件：自己墓地中存在卡名视为「魔瞳」、类型为魔法卡且可以作为代价除外的卡。
function s.cfilter(c)
	return c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②效果的代价处理：从自己墓地选择1张「魔瞳」魔法卡除外，作为发动无效攻击效果的代价。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己墓地是否存在至少1张满足s.cfilter条件的「魔瞳」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择1张要作为代价除外的「魔瞳」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的「魔瞳」魔法卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的「魔瞳」魔法卡以表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的处理：实际执行无效攻击，使对方怪兽的这次攻击无效化。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack无效当前攻击宣言。
	Duel.NegateAttack()
end
-- 条件统计用过滤：筛选自己墓地·除外状态中存在的「魔瞳」魔法卡（IsFaceupEx用于确认这些区域的表侧状态）。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1bb) and c:IsType(TYPE_SPELL)
end
-- ③效果的发动条件：自己墓地与除外状态中的「魔瞳」魔法卡种类数达到3种以上。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 计算满足条件的「魔瞳」魔法卡按卡名区分的种类数量，判断是否不少于3种。
	return Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=3
end
-- ③效果的对象/处理过滤：选择对方场上的表侧表示怪兽；op为true时选择全部，为false时只选择攻击力大于0的怪兽。
function s.atkfilter(c,op)
	return c:IsFaceup() and (op or c:GetAttack()>0)
end
-- ③效果发动时点：确认对方场上有至少1只攻击力大于0的表侧表示怪兽，并向对方提示发动了该效果；该效果不取对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③效果发动合法性检查：对方场上是否存在至少1只攻击力大于0的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,false) end
	-- 向对方玩家提示本方发动了「对方场上的全部怪兽攻击力变成0」的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ③效果的处理：将对方场上全部表侧表示怪兽的攻击力最终值设置为0，并为每只怪兽赋予不可被无效的攻击力设定效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前对方场上的全部表侧表示怪兽（不限制攻击力），作为攻击力变0的对象。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,true)
	-- 遍历对方场上的每一只表侧表示怪兽，逐一设置攻击力为0。
	for tc in aux.Next(g) do
		-- 对方场上的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
