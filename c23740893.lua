--妖仙獣 木魅
-- 效果：
-- 「妖仙兽 木魅」的①的效果1回合只能使用1次。
-- ①：把这张卡解放，以自己场上1张「修验的妖社」为对象才能发动。给那张卡放置3个妖仙指示物。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「妖仙兽」怪兽召唤。
function c23740893.initial_effect(c)
	-- ①：把这张卡解放，以自己场上1张「修验的妖社」为对象才能发动。给那张卡放置3个妖仙指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,23740893)
	e1:SetCost(c23740893.cost)
	e1:SetTarget(c23740893.target)
	e1:SetOperation(c23740893.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「妖仙兽」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23740893.sumtg)
	e2:SetOperation(c23740893.sumop)
	c:RegisterEffect(e2)
end
-- 将此卡解放作为费用
function c23740893.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从游戏中除外
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选满足条件的「修验的妖社」怪兽
function c23740893.filter(c)
	return c:IsFaceup() and c:IsCode(27918963) and c:IsCanAddCounter(0x33,3)
end
-- 选择1张自己场上的「修验的妖社」怪兽作为效果对象
function c23740893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c23740893.filter(chkc) end
	-- 检查场上是否存在满足条件的「修验的妖社」怪兽
	if chk==0 then return Duel.IsExistingTarget(c23740893.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示选择「修验的妖社」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23740893,0))  --"放置指示物"
	-- 选择1张自己场上的「修验的妖社」怪兽
	Duel.SelectTarget(tp,c23740893.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息为放置3个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x33)
end
-- 将3个妖仙指示物放置到选择的怪兽上
function c23740893.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x33,3)
	end
end
-- 检查是否可以通常召唤及额外召唤
function c23740893.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以通常召唤及额外召唤
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,23740893)==0 end
end
-- 设置额外召唤次数效果
function c23740893.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过此效果
	if Duel.GetFlagEffect(tp,23740893)~=0 then return end
	-- 设置额外召唤次数效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(23740893,1))  --"使用「妖仙兽 木魅」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为「妖仙兽」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb3))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册标识效果，防止效果重复使用
	Duel.RegisterFlagEffect(tp,23740893,RESET_PHASE+PHASE_END,0,1)
end
