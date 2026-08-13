--スクラップ・ブレイカー
-- 效果：
-- 对方场上存在怪兽的场合，这张卡可以从手卡特殊召唤。用这个方法把这张卡特殊召唤成功时，选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。
function c51555725.initial_effect(c)
	-- 对方场上存在怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c51555725.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 用这个方法把这张卡特殊召唤成功时，选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51555725,0))  --"名字带有「废铁」的怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c51555725.condition)
	e2:SetTarget(c51555725.target)
	e2:SetOperation(c51555725.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤手续的判定函数：先判定这个规则特殊召唤效果是否存在（c==nil时直接允许），而后检查对方场上有怪兽且自己主要怪兽区有空位，满足时才能从手卡特殊召唤。
function c51555725.spcon(e,c)
	if c==nil then return true end
	-- 检查对方场上是否存在怪兽（不限制表示形式，满足“对方场上存在怪兽”的场合条件）。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己的主要怪兽区是否有可用的空格子，确保能从手卡特殊召唤出来。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 诱发效果的条件判定：这张卡是否是通过「废铁破坏者」的规则效果特殊召唤成功（召唤类型为特殊召唤+SUMMON_VALUE_SELF），以此限定“用这个方法特殊召唤成功时”。
function c51555725.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选卡片的过滤器：选择表侧表示且字段为「废铁」（0x24）的怪兽。
function c51555725.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 发动时的取对象处理：先确认对象合法，再从自己场上选择1只表侧表示且含「废铁」字段的怪兽作为对象，并登记破坏相关的操作信息。
function c51555725.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51555725.filter(chkc) end
	if chk==0 then return true end
	-- 显示“请选择要破坏的卡”的选择提示框，供玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上筛选满足废铁字段且表侧表示的怪兽，从中选择1张作为效果对象并登记到当前连锁。
	local g=Duel.SelectTarget(tp,c51555725.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向系统登记本次效果的信息：这是破坏效果，对象为已选择的那些卡，数量为选择的数量，以便其他卡正确反应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得之前选择的对象，若它仍表侧表示且仍与这张卡的效果关联，就将其破坏。
function c51555725.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得在发动时选择的那个对象（目标卡片）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
