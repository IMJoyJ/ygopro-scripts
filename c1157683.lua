--サイバーダーク・インヴェイジョン
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。「电子暗黑侵略」的以下效果1回合各能选择1次。
-- ●以自己场上1只「电子暗黑」效果怪兽为对象才能发动。从自己·对方的墓地选1只龙族·机械族怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。
-- ●把给机械族怪兽装备的自己场上1张装备卡送去墓地才能发动。选对方场上1张卡破坏。
function c1157683.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，可以从以下效果选择1个发动。「电子暗黑侵略」的以下效果1回合各能选择1次。●以自己场上1只「电子暗黑」效果怪兽为对象才能发动。从自己·对方的墓地选1只龙族·机械族怪兽当作攻击力上升1000的装备卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1157683,0))  --"装备"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c1157683.eqtg)
	e1:SetOperation(c1157683.eqop)
	c:RegisterEffect(e1)
	-- ●把给机械族怪兽装备的自己场上1张装备卡送去墓地才能发动。选对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1157683,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c1157683.descost)
	e2:SetTarget(c1157683.destg)
	e2:SetOperation(c1157683.desop)
	c:RegisterEffect(e2)
end
-- 定义「电子暗黑」效果怪兽的对象过滤条件：自己场上表侧表示、属于电子暗黑系列0x4093，且自己或对方墓地存在至少1只可作为装备的龙族/机械族怪兽。
function c1157683.eqfilter(c,tp)
	return c:IsSetCard(0x4093) and c:IsFaceup() and c:IsType(TYPE_EFFECT)
		-- 检查自己或对方墓地是否存在至少1只满足 c1157683.eqfilter2 的龙族/机械族怪兽，确保后续有效果处理素材。
		and Duel.IsExistingMatchingCard(c1157683.eqfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
end
-- 墓地怪兽的过滤条件：种族为龙族或机械族，并且不是禁止卡，才能作为装备卡装备给对象怪兽。
function c1157683.eqfilter2(c)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and not c:IsForbidden()
end
-- 装备效果的发动判定与对象选择：指定对象时校验其为场上表侧表示的「电子暗黑」效果怪兽；无指定对象时确认自己魔陷区有空位且存在合法对象才可发动。
function c1157683.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1157683.eqfilter(chkc,tp) end
	-- 发动条件的一部分：我方场上不存在本回合已发动过装备效果的1157683标记，且我方魔陷区有可用空格。
	if chk==0 then return Duel.GetFlagEffect(tp,1157683)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且场上存在至少1只可选的表侧表示「电子暗黑」效果怪兽作为装备对象。
		and Duel.IsExistingTarget(c1157683.eqfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向对方玩家提示我方选择了发动哪个效果（显示效果描述），让对方确认操作。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 注册结束时重置的1157683标记，用于记录装备效果已经在本回合发动过，使该效果本回合不能再发动第二次。
	Duel.RegisterFlagEffect(tp,1157683,RESET_PHASE+PHASE_END,0,1)
	-- 弹出卡片选择提示，要求我方选择场上表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从我方场上选择1只满足条件的「电子暗黑」效果怪兽，将其设置为当前连锁的效果对象。
	Duel.SelectTarget(tp,c1157683.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本效果处理时预计有1张卡从墓地离开（作为装备卡装备到怪兽身上），分类为CATEGORY_LEAVE_GRAVE，供王家长眠之谷等效果参考。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 装备效果的实际处理：确认魔陷区有空格后，从自己/对方墓地选择1只龙族或机械族怪兽，作为装备卡装备到对象怪兽上，并附加只能装备给该对象和攻击力上升1000的效果。
function c1157683.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果我方魔陷区没有空位，则无法把墓地怪兽装备到场上，效果处理直接中止。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动时选择作为装备对象的「电子暗黑」效果怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 弹出选择提示，要求我方从墓地选择要装备的怪兽卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己/对方墓地选择1只满足种族/非禁止条件、且不受王家长眠之谷影响的龙族或机械族怪兽，作为要装备的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1157683.eqfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		local ec=g:GetFirst()
		-- 如果没能选到合法装备卡，或装备操作失败，则中止效果处理。
		if not ec or not Duel.Equip(tp,ec,tc) then return end
		-- 给作为对象的怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c1157683.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		-- 攻击力上升1000
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end
-- 装备限制判定：检查当前装备对象是否等于被指定的「电子暗黑」怪兽（标签对象），确保装备卡不会转移到其他怪兽身上。
function c1157683.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- cost过滤器：选择自己魔陷区表侧表示、当前装备给了机械族怪兽、且可以作为发动代价送去墓地的装备魔法卡。
function c1157683.cfilter(c)
	return c:IsFaceup() and c:GetEquipTarget() and c:GetEquipTarget():IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的cost处理：确认存在合法装备卡后，由我方选择1张装备给机械族怪兽的装备卡送去墓地作为发动代价。
function c1157683.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost发动条件：我方场上至少有1张装备给机械族怪兽且可以送墓的装备卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1157683.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 弹出选择提示，要求我方选择要送去墓地的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从我方魔陷区选择1张符合条件的装备卡。
	local g=Duel.SelectMatchingCard(tp,c1157683.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的装备卡以cost形式送去墓地，完成发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果目标判定：确认本回合未发动过破坏效果且对方场上有卡存在；由于不取对象，不在此阶段选择具体破坏目标。
function c1157683.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定我方场上不存在本回合已发动过破坏效果的1157684标记，以满足「1回合1次」的限制。
	if chk==0 then return Duel.GetFlagEffect(tp,1157684)==0
		-- 且对方场上有至少1张卡存在，作为可被破坏的对象。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示我方选择发动的是破坏效果，显示对应效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 注册结束时重置的1157684标记，用于记录破坏效果已经在本回合发动过，使该效果本回合不能再发动第二次。
	Duel.RegisterFlagEffect(tp,1157684,RESET_PHASE+PHASE_END,0,1)
	-- 获取对方场上的全部卡牌，作为不取对象破坏操作的可能目标集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将对方场上全部卡作为可能破坏对象，预计破坏1张，分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理：效果处理时从对方场上选择1张卡进行破坏，并播放被选中动画，实际执行破坏。
function c1157683.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求我方选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为实际破坏对象（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 为被选中的卡播放被选择动画，并记录其被作为对象。
		Duel.HintSelection(g)
		-- 以效果原因破坏选择的那张卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
