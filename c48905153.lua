--十二獣ドランシア
-- 效果：
-- 4星怪兽×4
-- 「十二兽 龙枪」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c48905153.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,4,c48905153.ovfilter,aux.Stringid(48905153,0),4,c48905153.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c48905153.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c48905153.defval)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48905153,1))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c48905153.descost)
	e3:SetTarget(c48905153.destg)
	e3:SetOperation(c48905153.desop)
	c:RegisterEffect(e3)
end
-- 判断是否满足作为超量素材的「十二兽」怪兽条件（必须是表侧表示、属于「十二兽」卡组且不是自身）。
function c48905153.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(48905153)
end
-- 检查是否已使用过该效果（通过标识效果判断），若未使用则注册一个标识效果以限制只能发动一次。
function c48905153.xyzop(e,tp,chk)
	-- 检查是否已使用过该效果（通过标识效果判断），若未使用则允许发动。
	if chk==0 then return Duel.GetFlagEffect(tp,48905153)==0 end
	-- 为玩家注册一个全局标识效果，用于标记该回合已使用过此效果，并在结束阶段重置。
	Duel.RegisterFlagEffect(tp,48905153,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选作为超量素材的「十二兽」怪兽中攻击力大于等于0的怪兽。
function c48905153.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算当前叠加怪兽中所有满足条件的「十二兽」怪兽的攻击力总和，作为自身攻击力提升值。
function c48905153.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c48905153.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 筛选作为超量素材的「十二兽」怪兽中守备力大于等于0的怪兽。
function c48905153.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算当前叠加怪兽中所有满足条件的「十二兽」怪兽的守备力总和，作为自身守备力提升值。
function c48905153.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c48905153.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 检查是否能从自身移除1个超量素材作为发动代价，并执行移除操作。
function c48905153.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择场上一张表侧表示的卡作为破坏对象，并设置连锁操作信息。
function c48905153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 判断是否存在满足条件的目标卡片（即场上一张表侧表示的卡）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向对方提示“对方选择了：卡片破坏”效果发动。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择一张表侧表示的卡作为目标。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明将要破坏选定的目标卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏操作：若目标卡仍存在于场，则将其破坏。
function c48905153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
