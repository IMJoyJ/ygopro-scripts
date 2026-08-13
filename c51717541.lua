--インフェルニティ・ブレイク
-- 效果：
-- 自己手卡是0张的场合才能发动。选择自己墓地存在的1张名字带有「永火」的卡从游戏中除外，选择对方场上存在的1张卡破坏。
function c51717541.initial_effect(c)
	-- 自己手卡是0张的场合才能发动。选择自己墓地存在的1张名字带有「永火」的卡从游戏中除外，选择对方场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c51717541.condition)
	e1:SetTarget(c51717541.target)
	e1:SetOperation(c51717541.activate)
	c:RegisterEffect(e1)
end
-- 定义本卡发动条件的判定函数：仅当自己手牌数为0时，本卡才能发动。
function c51717541.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手牌区域（LOCATION_HAND）的卡牌数量，并判断其是否为0；若为0则发动条件成立。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义筛选函数：从自己墓地中筛选出名字带有「永火」(0xb)且可以被除外的卡，作为本卡除外效果的对象。
function c51717541.filter(c)
	return c:IsSetCard(0xb) and c:IsAbleToRemove()
end
-- 定义效果发动时的目标选择与合法性检查：先确认合法对象是否存在，若存在则让玩家分别选择墓地中要除外的「永火」卡和对方场上要破坏的卡。
function c51717541.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动合法性检查（chk==0）时，确认对方场上是否存在至少1张可以被选择为对象（aux.TRUE表示任意卡）的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		-- 同时确认自己墓地是否存在至少1张满足「永火」且可除外的卡可以作为对象；两者同时存在时本卡才能发动。
		and Duel.IsExistingTarget(c51717541.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示消息，引导玩家选择除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张名字带有「永火」且能够被除外的卡，并将其登记为效果对象（取对象）。
	local g1=Duel.SelectTarget(tp,c51717541.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向玩家显示“请选择要破坏的卡”的提示消息，引导玩家选择破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡（aux.TRUE表示不限制卡种）作为破坏对象，并将其登记为效果对象（取对象）。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁的处理信息：将要执行除外操作，对象为g1（墓地的「永火」卡），数量为1，位置为自己墓地，用于发动时点检测等判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,tp,LOCATION_GRAVE)
	-- 登记本次连锁的处理信息：将要执行破坏操作，对象为g2（对方场上的卡），数量为1，用于发动时点检测等判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 定义效果处理函数：先除外之前选择的墓地「永火」卡，若成功除外，再破坏之前选择的对方场上的卡。
function c51717541.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与本效果相关的所有对象卡（即发动时选择的两张目标卡），并存入集合g。
	local g=Duel.GetTargetsRelateToChain()
	local rm=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	-- 从集合g中筛选出位于墓地的卡rm，若存在且成功以表侧表示除外（原因是效果），则继续执行后续破坏处理。
	if rm and Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)>0 then
		local ds=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD):GetFirst()
		if ds then
			-- 将对方场上的对象卡ds以效果破坏（送入墓地）。
			Duel.Destroy(ds,REASON_EFFECT)
		end
	end
end
