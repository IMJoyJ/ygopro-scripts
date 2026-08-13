--借カラクリ旅籠蔵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「机巧」怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽的效果直到回合结束时无效。
-- ②：自己场上有「机巧」怪兽存在的场合，把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
function c3693034.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「机巧」怪兽和对方场上1只效果怪兽为对象才能发动。那只自己怪兽的表示形式变更，那只对方怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,3693034+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3693034.target)
	e1:SetOperation(c3693034.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「机巧」怪兽存在的场合，把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3693034,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c3693034.poscon)
	-- 为②效果设置发动代价：把墓地的这张卡除外。aux.bfgcost 会在发动前检查该卡能否从墓地除外，并在发动时将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c3693034.postg)
	e2:SetOperation(c3693034.posop)
	c:RegisterEffect(e2)
end
-- 定义①效果选择自己场上「机巧」怪兽的筛选条件：表侧表示、属于「机巧」字段（SetCard 0x11）、且可以变更表示形式。此过滤器用于选择自己要变更表示形式的对象怪兽。
function c3693034.posfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- ①效果的 target 函数（前半部分）：处理连锁过程的对象合法性确认和发动条件检查。若传入待确认对象 chkc 则直接判定不合法（因本效果需同时选择两个对象，无法以单个 chkc 确认）；在 chk==0 时检查自己场上是否有可选的「机巧」怪兽、对方场上是否有可被无效的效果怪兽，作为发动条件。
function c3693034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动条件检查：确认自己场上存在至少1只满足 posfilter1 条件的表侧「机巧」怪兽，可供选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c3693034.posfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 效果发动条件检查（续）：确认对方场上存在至少1只满足 aux.NegateEffectMonsterFilter 的表侧效果怪兽，可供选择为无效对象。
		and Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示消息，提示内容为“请选择要改变表示形式的怪兽”，为接下来选择自己「机巧」怪兽做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让当前玩家从自己怪兽区域选择1只符合 posfilter1 的「机巧」怪兽，并将其登记为本连锁的对象（SelectTarget 还会将所选卡设为当前效果对象）。
	local g1=Duel.SelectTarget(tp,c3693034.posfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 向当前玩家显示选择提示消息，提示内容为“请选择要无效的卡”，为接下来选择对方效果怪兽做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让当前玩家从对方怪兽区域选择1只符合 aux.NegateEffectMonsterFilter 的表侧效果怪兽，并将其登记为本连锁的对象。
	local g2=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本效果将变更 g1（自己选择的「机巧」怪兽）的表示形式（CATEGORY_POSITION），数量为1，供其他效果或系统检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,1,0,0)
	-- 设置操作信息：声明本效果将无效 g2（对方效果怪兽）的效果（CATEGORY_DISABLE），数量为1，供其他效果或系统检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- ①效果处理时执行的实际操作：用 e:GetLabelObject() 取得发动时选择自己怪兽 hc，从连锁对象组中排除 hc 后得到对方怪兽 tc；若 hc 仍与效果关联且由自己控制，则变更其表示形式；若 tc 仍与效果关联且为对方场上的表侧效果怪兽，则将其效果无效化并使其相关连锁也被无效，该无效持续到回合结束。
function c3693034.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 取得当前连锁效果记录的全部对象卡片组（Group），其中包含①效果选择的自己怪兽和对方怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	-- 处理自己怪兽的表示形式变更：确认该怪兽仍与效果关联且由自己控制后，将其在表侧攻击表示与表侧守备表示之间切换（Duel.ChangePosition 的四个参数分别对应表侧攻击、里侧攻击、表侧守备、里侧守备的最终形式，这里实际是让表侧攻击变表侧守备、表侧守备变表侧攻击）。若变更成功（返回值非0），才继续处理对方怪兽的无效化。
	if hc:IsRelateToEffect(e) and hc:IsControler(tp) and Duel.ChangePosition(hc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与对方怪兽相关联的连锁（如该怪兽已发动的效果连锁）被无效化，并在该怪兽变更为里侧表示时重置这一无效关系。这是效果无效化处理的一环。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 定义用于检查自己场上是否存在「机巧」怪兽的过滤函数：怪兽须表侧表示且属于「机巧」字段（SetCard 0x11）。该过滤函数用于②效果的发动条件判断。
function c3693034.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11)
end
-- ②效果的发动条件函数：检查自己场上是否存在至少1只表侧表示「机巧」怪兽，若存在，则允许从墓地发动②效果。
function c3693034.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行条件检查：在自己怪兽区域寻找至少1张满足 cfilter 的表侧「机巧」怪兽，找到则返回 true。
	return Duel.IsExistingMatchingCard(c3693034.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义②效果选择场上怪兽的过滤条件：怪兽须表侧表示且可以变更表示形式。用于选择任意要被变更表示形式的表侧怪兽。
function c3693034.posfilter2(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ②效果的 target 函数：先处理连锁验证（若传入 chkc，则要求该卡位于怪兽区域且满足 posfilter2）；然后检查双方怪兽区域是否存在可选对象；若可发动，则提示玩家选择1只场上表侧表示怪兽作为对象，并设置变更表示形式的操作信息。
function c3693034.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3693034.posfilter2(chkc) end
	-- 效果发动条件检查：确认双方怪兽区域合计存在至少1只满足 posfilter2 条件的表侧表示怪兽，以保证可选择对象。
	if chk==0 then return Duel.IsExistingTarget(c3693034.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示选择提示消息，提示内容为“请选择要改变表示形式的怪兽”，为选择对象做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让当前玩家从双方怪兽区域选择1只符合 posfilter2 的表侧表示怪兽，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c3693034.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本效果将变更 g（选择的对象）的表示形式（CATEGORY_POSITION），数量为1，供其他效果或系统检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理时执行的操作：取得效果对象，确认其仍与效果关联后，将该表侧怪兽的表示形式在表侧攻击与表侧守备之间切换。
function c3693034.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个目标怪兽，即②效果选择的场上表侧表示怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更目标怪兽的表示形式：若为表侧攻击表示则变成表侧守备表示，若为表侧守备表示则变成表侧攻击表示（Duel.ChangePosition 接收四种目标表示形式参数，这里用于攻守互换）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
