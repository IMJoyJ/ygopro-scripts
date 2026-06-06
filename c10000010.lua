--ラーの翼神竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c10000010.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000010,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000010.ttcon)
	e1:SetOperation(c10000010.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000010.setcon)
	c:RegisterEffect(e2)
	-- ①：这张卡的召唤不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000010.sumsuc)
	c:RegisterEffect(e4)
	-- 这张卡不能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c10000010.splimit)
	c:RegisterEffect(e5)
	-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10000010,0))  --"攻守上升"
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCost(c10000010.atkcost)
	e6:SetOperation(c10000010.atkop)
	c:RegisterEffect(e6)
	-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 召唤条件判断：检查是否满足3只解放的要求，且场上有3个可用于召唤的祭品
function c10000010.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查玩家是否能提供3只解放作召唤
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 召唤操作的执行：选择3只祭品解放，并为该卡设置解放素材
function c10000010.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择3只用于通常召唤该卡的解放怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选取的怪兽
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置条件限制：直接返回false，使得此卡不能被里侧表示放置
function c10000010.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 特殊召唤限制条件：通常情况下不能特殊召唤，但在特定效果影响下可以特殊召唤
function c10000010.splimit(e,se,sp,st)
	-- 检查玩家是否受到允许特殊召唤太阳神之翼神龙的效果影响
	return Duel.IsPlayerAffectedByEffect(sp,41044418)
		and (st&SUMMON_VALUE_MONSTER_REBORN>0 or se:GetHandler():IsCode(83764718))
		and e:GetHandler():IsControler(sp) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 生成阻止连锁的函数，该函数限制除了此卡之外的其他卡的效果的发动
function c10000010.genchainlm(c)
	return	function (e,rp,tp)
				return e:GetHandler()==c
			end
end
-- 召唤成功时的处理：设置连锁限制，使除了此卡之外双方都不能把卡的效果发动
function c10000010.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置直到连锁结束前双方不能把卡的效果发动
	Duel.SetChainLimitTillChainEnd(c10000010.genchainlm(e:GetHandler()))
end
-- 攻守上升效果代价：检查是否能够支付并支付LP直到变成100，将支付的LP数值保存在效果的标签中
function c10000010.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前的LP值
	local lp=Duel.GetLP(tp)
	-- 检查玩家是否能支付LP直到变成100
	if chk==0 then return Duel.CheckLPCost(tp,lp-100,true) end
	e:SetLabel(lp-100)
	-- 让玩家支付LP直到变成100点
	Duel.PayLPCost(tp,lp-100,true)
end
-- 攻守上升效果执行：使此卡的攻击力和守备力上升所支付的LP数值
function c10000010.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
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
-- 破坏效果代价：检查是否能支付且支付1000LP
function c10000010.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000LP
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000LP
	Duel.PayLPCost(tp,1000)
end
-- 破坏效果的目标确定：选择场上1只怪兽作为效果的对象，并设置操作信息为破坏
function c10000010.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏所选的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行：如果目标在场上，将其破坏
function c10000010.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
