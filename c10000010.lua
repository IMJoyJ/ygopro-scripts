--ラーの翼神竜
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把3只解放作召唤。
-- ①：这张卡的召唤不会被无效化。
-- ②：在这张卡的召唤成功时双方不能把其他卡的效果发动。
-- ③：这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值。
-- ④：支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c10000010.initial_effect(c)
	-- 这张卡通常召唤的场合，必须把3只解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000010,2))  --"把3只解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000010.ttcon)
	e1:SetOperation(c10000010.ttop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡不能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SET_PROC)
	e2:SetCondition(c10000010.setcon)
	c:RegisterEffect(e2)
	-- 这张卡的召唤不会被无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	-- 在这张卡的召唤成功时双方不能把其他卡的效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c10000010.sumsuc)
	c:RegisterEffect(e4)
	-- 这张卡不能特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c10000010.splimit)
	c:RegisterEffect(e5)
	-- 这张卡召唤时，把基本分支付到变成100基本分才能发动。这张卡的攻击力·守备力上升支付的数值
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(10000010,0))  --"攻守上升"
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetCost(c10000010.atkcost)
	e6:SetOperation(c10000010.atkop)
	c:RegisterEffect(e6)
	-- 支付1000基本分，以场上1只怪兽为对象才能发动。那只怪兽破坏
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
-- 判断是否满足通常召唤需要3只祭品的条件
function c10000010.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查场上是否存在3只可用祭品
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 设置召唤所用祭品并进行解放
function c10000010.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3只祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选择的祭品进行解放
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 判断是否满足特殊召唤条件
function c10000010.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 判断是否满足特殊召唤限制条件
function c10000010.splimit(e,se,sp,st)
	-- 检查玩家是否受到效果影响
	return Duel.IsPlayerAffectedByEffect(sp,41044418)
		and (st&SUMMON_VALUE_MONSTER_REBORN>0 or se:GetHandler():IsCode(83764718))
		and e:GetHandler():IsControler(sp) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 生成连锁限制函数
function c10000010.genchainlm(c)
	return	function (e,rp,tp)
				return e:GetHandler()==c
			end
end
-- 处理召唤成功后的连锁限制设置
function c10000010.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到当前连锁结束
	Duel.SetChainLimitTillChainEnd(c10000010.genchainlm(e:GetHandler()))
end
-- 处理攻击力上升效果的费用支付
function c10000010.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家的基本分
	local lp=Duel.GetLP(tp)
	-- 检查是否能支付费用
	if chk==0 then return Duel.CheckLPCost(tp,lp-100,true) end
	e:SetLabel(lp-100)
	-- 支付基本分费用
	Duel.PayLPCost(tp,lp-100,true)
end
-- 处理攻击力守备力上升效果
function c10000010.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置攻击力上升效果
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
-- 处理破坏效果的费用支付
function c10000010.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付费用
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付基本分费用
	Duel.PayLPCost(tp,1000)
end
-- 处理选择目标怪兽
function c10000010.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理破坏效果
function c10000010.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
