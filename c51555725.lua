--スクラップ・ブレイカー
-- 效果：
-- 对方场上存在怪兽的场合，这张卡可以从手卡特殊召唤。用这个方法把这张卡特殊召唤成功时，选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。
function c51555725.initial_effect(c)
	-- 效果原文内容：对方场上存在怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c51555725.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：用这个方法把这张卡特殊召唤成功时，选择自己场上表侧表示存在的1只名字带有「废铁」的怪兽破坏。
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
-- 规则层面操作：判断是否满足特殊召唤条件，即对方场上有怪兽且自身有可用召唤区域。
function c51555725.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查对方场上是否存在怪兽数量大于0。
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 规则层面操作：检查自身主怪兽区是否有可用空位。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规则层面操作：判断该卡是否为特殊召唤成功（通过特定方式召唤）
function c51555725.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 规则层面操作：过滤名字带有「废铁」的表侧表示怪兽
function c51555725.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x24)
end
-- 规则层面操作：设置选择目标时的提示信息并选取一个符合条件的目标怪兽
function c51555725.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51555725.filter(chkc) end
	if chk==0 then return true end
	-- 规则层面操作：向玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：从己方场上选择一只名字带有「废铁」的表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c51555725.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 规则层面操作：设置连锁的操作信息，表明将要破坏选定的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 规则层面操作：执行破坏效果，对选定的目标怪兽进行破坏处理
function c51555725.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中被指定的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面操作：以效果为原因将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
