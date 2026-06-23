--ラーの翼神竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c10000010.initial_effect(c)
	-- 创建效果，设置描述为“把3只解放作召唤”，不可失效且不能复制，类型为单次，限制召唤流程，条件为c10000010.ttcon，操作为c10000010.ttop，值为上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000010,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000010.ttcon)
	e1:SetOperation(c10000010.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 创建效果，类型为单次，限制放置流程，条件为c10000010.setcon。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000010.setcon)
	c:RegisterEffect(e2)
	-- 创建效果，类型为单次，代码为EFFECT_CANNOT_DISABLE_SUMMON，属性为不可失效且不能复制。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 创建效果，类型为单次+连续，代码为EVENT_SUMMON_SUCCESS，操作为c10000010.sumsuc。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000010.sumsuc)
	c:RegisterEffect(e4)
	-- 创建效果，设置属性为不可失效且不能复制，类型为单次，代码为EFFECT_SPSUMMON_CONDITION，值为c10000010.splimit。
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c10000010.splimit)
	c:RegisterEffect(e5)
	-- 创建效果，设置描述为“攻守上升”，分类为改变攻击效果，类型为触发型单次，代码为EVENT_SUMMON_SUCCESS，费用为c10000010.atkcost，操作为c10000010.atkop。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10000010,0))  --"攻守上升"
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCost(c10000010.atkcost)
	e6:SetOperation(c10000010.atkop)
	c:RegisterEffect(e6)
	-- 创建效果，设置描述为“破坏”，分类为破坏效果，类型为起动型，属性为取对象，范围为怪兽区域，费用为c10000010.descost，目标为c10000010.destg，操作为c10000010.desop。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(10000010,1))  --"破坏"
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCost(c10000010.descost)
	e7:SetTarget(c10000010.destg)
	e7:SetOperation(c10000010.desop)
	c:RegisterEffect(e7)
end
-- 判断召唤祭品数量是否小于等于3且存在满足条件的祭品。
function c10000010.ttcon(e,c,minc)
	if c==nil then return true end
	-- 返回minc<=3 and Duel.CheckTribute(c,3)
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 选择用于通常召唤的3只怪兽，将选出的怪兽设置为卡片的素材，并以REASON_SUMMON+REASON_MATERIAL的原因解放它们。
function c10000010.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从场上选择3只怪兽作为祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 以REASON_SUMMON和REASON_MATERIAL原因释放选定的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 设置条件为假，表示这张卡不能通常召唤。
function c10000010.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 判断玩家是否受到效果影响，以及满足特殊召唤的条件（复活怪兽或代码为83764718），并且处理对象是控制者且在墓地。
function c10000010.splimit(e,se,sp,st)
	-- 检查玩家sp是否受到效果41044418的影响
	return Duel.IsPlayerAffectedByEffect(sp,41044418)
		and (st&SUMMON_VALUE_MONSTER_REBORN>0 or se:GetHandler():IsCode(83764718))
		and e:GetHandler():IsControler(sp) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 定义一个函数，返回一个匿名函数，用于判断当前连锁的处理对象是否为卡片c。
function c10000010.genchainlm(c)
	return	function (e,rp,tp)
				return e:GetHandler()==c
			end
end
-- 设置链条限制直到链条结束，使用genchainlm函数生成的条件。
function c10000010.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置链条限制，确保只有这张卡的连锁才能继续。
	Duel.SetChainLimitTillChainEnd(c10000010.genchainlm(e:GetHandler()))
end
-- 检查玩家的LP是否足够支付100点，如果可以则将支付的LP数量设置为效果标签。
function c10000010.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家的生命值
	local lp=Duel.GetLP(tp)
	-- 检查玩家是否能够支付100点生命值
	if chk==0 then return Duel.CheckLPCost(tp,lp-100,true) end
	e:SetLabel(lp-100)
	-- 让玩家支付100点生命值
	Duel.PayLPCost(tp,lp-100,true)
end
-- 创建效果，类型为单次，属性为单卡范围，作用区域为怪兽区，代码为EFFECT_UPDATE_ATTACK，值为e:GetLabel()，重置条件为RESET_EVENT+RESETS_STANDARD+RESET_DISABLE。
function c10000010.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个单次效果，用于更新攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
-- 检查玩家是否能够支付1000点LP，如果可以则支付。
function c10000010.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 判断目标卡片是否在怪兽区域，并且检查是否存在可作为破坏目标的卡片。如果存在，则提示选择要破坏的卡片，并设置操作信息。
function c10000010.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否有满足条件的卡片可以被选为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示消息，要求其选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从怪兽区域选择一张卡片作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示这是一个破坏效果，并且指定了目标卡片和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 获取当前连锁的第一个目标卡片，如果该卡片与效果相关，则以REASON_EFFECT的原因将其破坏。
function c10000010.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以REASON_EFFECT原因破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
