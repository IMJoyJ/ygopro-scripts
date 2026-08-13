--超重武者装留ビッグバン
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力上升1000的装备卡使用给那只怪兽装备。
-- ②：自己场上有守备表示的「超重武者」怪兽存在，对方在战斗阶段把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。那之后，场上的怪兽全部破坏，双方玩家受到1000伤害。
function c3064425.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。自己的手卡·场上的这只怪兽当作守备力上升1000的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3064425,0))  --"给「超重武者」怪兽装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c3064425.eqtg)
	e1:SetOperation(c3064425.eqop)
	c:RegisterEffect(e1)
	-- ②：自己场上有守备表示的「超重武者」怪兽存在，对方在战斗阶段把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个发动无效并破坏。那之后，场上的怪兽全部破坏，双方玩家受到1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3064425,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c3064425.negcon)
	-- 设置效果的发动代价为把墓地的这张卡除外（通过aux.bfgcost函数实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3064425.negtg)
	e2:SetOperation(c3064425.negop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：怪兽须表侧表示且属于「超重武者」字段（0x9a）。
function c3064425.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果①的发动与取目标判定：目标必须是自己场上表侧表示的超重武者怪兽；发动还需满足魔陷区有空位且存在可选对象。
function c3064425.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3064425.filter(chkc) end
	-- 发动条件检查：自己魔陷区必须存在空位，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：自己场上存在1只符合过滤器条件的「超重武者」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c3064425.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择提示信息，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的超重武者怪兽作为装备对象，并设置为效果对象。
	Duel.SelectTarget(tp,c3064425.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果①的处理：将这张卡装备给对象怪兽；若装备条件不成立则送去墓地；装备后赋予装备限制和守备力上升1000的效果。
function c3064425.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得效果①选择的对象怪兽（要装备的超重武者）。
	local tc=Duel.GetFirstTarget()
	-- 检查是否仍满足装备条件：自己魔陷区有空位、对象仍在自己场上、对象表侧表示且与效果正常关联。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若无法进行装备，则将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 装备限制效果：该装备卡只能装备给「超重武者」怪兽，对应原文“给那只怪兽装备”的装备限制。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c3064425.eqlimit)
	c:RegisterEffect(e1)
	-- 装备效果：装备怪兽的守备力上升1000，对应原文“守备力上升1000”。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定函数：只有「超重武者」字段的怪兽才能装备这张卡。
function c3064425.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 定义过滤器：怪兽须表侧守备表示且属于「超重武者」字段。
function c3064425.cfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x9a)
end
-- 效果②的发动条件：对面发动效果、当前为战斗阶段、自己场上有表侧守备表示的超重武者怪兽存在。
function c3064425.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段并存入变量ph，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判定条件：对方发动效果、该连锁可以被无效、且当前阶段为战斗阶段（主阶1之后、主阶2之前）。
	return ep~=tp and Duel.IsChainNegatable(ev) and ph>PHASE_MAIN1 and ph<PHASE_MAIN2
		-- 追加判定：自己场上有表侧守备表示的超重武者怪兽存在。
		and Duel.IsExistingMatchingCard(c3064425.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的目标与操作信息设置：登记无效对象、破坏场上全部怪兽、双方玩家各受1000伤害。
function c3064425.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的效果（eg）登记为无效对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 取得场上所有怪兽（双方场上的全部怪兽）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏对象为场上全部怪兽，数量为所取得怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：双方玩家各受到1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000)
end
-- 效果②的处理：先无效并破坏对方发动的效果，随后破坏场上全部怪兽，最后双方各受1000伤害。
function c3064425.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若无效成功、对方效果卡仍与效果关联，且破坏该效果卡成功，则继续后续处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使“无效并破坏”与后续“全场破坏和伤害”作为不同时点处理。
		Duel.BreakEffect()
		-- 再次取得场上所有怪兽，用于后续的破坏处理。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 若场上怪兽未被破坏（破坏数量为0），则不再执行伤害处理。
		if Duel.Destroy(g,REASON_EFFECT)==0 then return end
		-- 给效果发动者（自己）造成1000点伤害，使用分步伤害处理。
		Duel.Damage(tp,1000,REASON_EFFECT,true)
		-- 给对方造成1000点伤害，使用分步伤害处理。
		Duel.Damage(1-tp,1000,REASON_EFFECT,true)
		-- 完成伤害分步处理，触发相关时点。
		Duel.RDComplete()
	end
end
