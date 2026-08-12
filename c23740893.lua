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
	-- 设置②效果的代价：把墓地的这张卡除外才能发动
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23740893.sumtg)
	e2:SetOperation(c23740893.sumop)
	c:RegisterEffect(e2)
end
c23740893.mentioned_counter={
	[0x33]=true,
}
-- ①效果的代价处理：确认这张卡可以解放，并将其解放作为发动代价
function c23740893.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价原因把这张卡解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤器：筛选自己场上表侧表示的「修验的妖社」且可以放置3个妖仙指示物的卡
function c23740893.filter(c)
	return c:IsFaceup() and c:IsCode(27918963) and c:IsCanAddCounter(0x33,3)
end
-- ①效果的对象选择处理：以自己场上1张满足条件的「修验的妖社」为对象，并设置指示物效果的操作信息
function c23740893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c23740893.filter(chkc) end
	-- 检查自己场上是否存在可以成为对象、能放置3个妖仙指示物的「修验的妖社」
	if chk==0 then return Duel.IsExistingTarget(c23740893.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23740893,0))  --"放置指示物"
	-- 以自己场上1张满足条件的「修验的妖社」为对象
	Duel.SelectTarget(tp,c23740893.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：给对象卡放置3个妖仙指示物（CATEGORY_COUNTER）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x33)
end
-- ①效果的处理：若对象卡仍为表侧表示且与本效果关联，则给其放置3个妖仙指示物
function c23740893.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x33,3)
	end
end
-- ②效果的发动条件检查：自己可以通常召唤、有额外召唤次数且本回合尚未使用过此效果
function c23740893.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己可以通常召唤、还有通常召唤外的召唤次数，且这个回合尚未适用过「妖仙兽 木魅」的②效果
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,23740893)==0 end
end
-- ②效果的处理：为玩家注册一个持续到回合结束的效果，使其在通常召唤外可以再把1只「妖仙兽」怪兽召唤，并登记本回合已适用
function c23740893.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若这个回合已经适用过此效果则不再处理
	if Duel.GetFlagEffect(tp,23740893)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「妖仙兽」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(23740893,1))  --"使用「妖仙兽 木魅」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设定增加召唤次数效果只对手卡的「妖仙兽」怪兽（卡包0xb3）适用
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb3))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把该增加召唤次数的效果注册给玩家全局环境
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合内持续1次的标识效果，标记「妖仙兽 木魅」的②效果这个回合已适用
	Duel.RegisterFlagEffect(tp,23740893,RESET_PHASE+PHASE_END,0,1)
end
