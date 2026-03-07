--超重武者装留ビッグバン
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力上升1000的装备卡使用给那只怪兽装备。
-- ②：自己场上有守备表示的「超重武者」怪兽存在，对方在战斗阶段把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。那之后，场上的怪兽全部破坏，双方玩家受到1000伤害。
function c3064425.initial_effect(c)
	-- 效果原文内容：①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力上升1000的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3064425,0))  --"给「超重武者」怪兽装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c3064425.eqtg)
	e1:SetOperation(c3064425.eqop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上有守备表示的「超重武者」怪兽存在，对方在战斗阶段把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。那之后，场上的怪兽全部破坏，双方玩家受到1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3064425,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c3064425.negcon)
	-- 规则层面操作：将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3064425.negtg)
	e2:SetOperation(c3064425.negop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：过滤满足条件的「超重武者」怪兽
function c3064425.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 规则层面操作：检查是否满足装备条件
function c3064425.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3064425.filter(chkc) end
	-- 规则层面操作：检查场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面操作：检查场上是否存在满足条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c3064425.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 规则层面操作：提示选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面操作：选择目标怪兽
	Duel.SelectTarget(tp,c3064425.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 规则层面操作：处理装备效果
function c3064425.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 规则层面操作：获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面操作：检查装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 规则层面操作：将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 规则层面操作：将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 效果原文内容：将装备卡的装备对象限制为「超重武者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c3064425.eqlimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：装备卡使目标怪兽的守备力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 规则层面操作：限制装备对象为「超重武者」怪兽
function c3064425.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 规则层面操作：过滤场上的守备表示的「超重武者」怪兽
function c3064425.cfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x9a)
end
-- 规则层面操作：判断是否满足发动条件
function c3064425.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 规则层面操作：判断是否为对方发动效果且在主要阶段中
	return ep~=tp and Duel.IsChainNegatable(ev) and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
		-- 规则层面操作：检查场上是否存在守备表示的「超重武者」怪兽
		and Duel.IsExistingMatchingCard(c3064425.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面操作：设置发动效果的操作信息
function c3064425.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 规则层面操作：获取场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 规则层面操作：设置破坏场上的所有怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 规则层面操作：设置双方各受到1000伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 规则层面操作：处理效果发动后的处理
function c3064425.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否成功无效发动并破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 规则层面操作：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面操作：获取场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 规则层面操作：判断是否成功破坏所有怪兽
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		-- 规则层面操作：给与自己1000伤害
		Duel.Damage(tp,1000,REASON_EFFECT,true)
		-- 规则层面操作：给与对方1000伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		-- 规则层面操作：触发伤害处理完成时点
		Duel.RDComplete()
	end
end
