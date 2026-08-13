--十二獣ドランシア
-- 效果：
-- 4星怪兽×4
-- 「十二兽 龙枪」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c48905153.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,4,c48905153.ovfilter,aux.Stringid(48905153,0),4,c48905153.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
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
-- 筛选可作为叠放素材的怪兽：必须是表侧表示、属于「十二兽」字段、且卡名不是「十二兽 龙枪」的自己场上的「十二兽」怪兽。
function c48905153.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(48905153)
end
-- 处理「十二兽 龙枪」在「十二兽」怪兽上面重叠来超量召唤的追加召唤手续；检测并登记本回合是否已经使用过该召唤方式。
function c48905153.xyzop(e,tp,chk)
	-- 在费用/发动条件检查阶段，确认当前玩家本回合尚未使用过该叠放召唤方式（对应1回合1次的限制）。
	if chk==0 then return Duel.GetFlagEffect(tp,48905153)==0 end
	-- 为当前玩家登记本回合已使用过该叠放召唤方式的标志，并在结束阶段重置，同时附加誓约标记以保证1回合1次。
	Duel.RegisterFlagEffect(tp,48905153,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选超量素材中能提供攻击力数值的「十二兽」怪兽（攻击力大于等于0）。
function c48905153.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 获取这张卡全部超量素材中满足条件的「十二兽」怪兽，将这些怪兽各自的攻击力合计作为这张卡攻击力的上升数值。
function c48905153.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c48905153.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 筛选超量素材中能提供守备力数值的「十二兽」怪兽（守备力大于等于0）。
function c48905153.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 获取这张卡全部超量素材中满足条件的「十二兽」怪兽，将这些怪兽各自的守备力合计作为这张卡守备力的上升数值。
function c48905153.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c48905153.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 效果②的发动代价：检查是否可以取除这张卡的1个超量素材，并实际取除1个超量素材作为COST。
function c48905153.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动目标处理：选择场上1张表侧表示卡为对象，检查是否存在合法对象，并设置破坏相关的连锁信息。
function c48905153.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动条件检查：场上是否存在至少1张表侧表示卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示我方选择了发动「卡片破坏」效果，并显示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 为当前玩家弹出选择提示，提示文字为『请选择要破坏的卡』，用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张表侧表示的卡作为效果对象，并将其自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息，声明将破坏1张对象卡，供相关效果（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②处理时：取得之前选择的对象卡，若该卡仍与效果关联，则将其破坏。
function c48905153.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将该对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
