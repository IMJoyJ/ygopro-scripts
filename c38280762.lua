--紫炎の老中 エニシ
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
function c38280762.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为假，即不能通常召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己墓地2只名字带有「六武众」的怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c38280762.spcon)
	e2:SetTarget(c38280762.sptg)
	e2:SetOperation(c38280762.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以选择场上表侧表示存在的1只怪兽破坏。这个效果发动的回合，这张卡不能攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38280762,0))  --"表侧表示存在的1只怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c38280762.descost)
	e3:SetTarget(c38280762.destg)
	e3:SetOperation(c38280762.desop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的墓地六武众怪兽（怪兽类型、可除外作为费用）
function c38280762.spfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足特殊召唤条件：场上存在空位且墓地存在2只符合条件的六武众怪兽
function c38280762.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在2只符合条件的六武众怪兽
		and Duel.IsExistingMatchingCard(c38280762.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 选择并除外2只符合条件的六武众怪兽
function c38280762.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有符合条件的六武众怪兽
	local g=Duel.GetMatchingGroup(c38280762.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤时的除外操作
function c38280762.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 支付破坏效果的费用：本回合未攻击宣言
function c38280762.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 设置本回合不能攻击宣言的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤场上表侧表示存在的怪兽
function c38280762.desfilter(c)
	return c:IsFaceup()
end
-- 设置破坏效果的目标选择逻辑
function c38280762.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38280762.desfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示存在的怪兽作为目标
	local g=Duel.SelectTarget(tp,c38280762.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c38280762.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
