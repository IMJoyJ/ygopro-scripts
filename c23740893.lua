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
c23740893.mentioned_counter={
	[0x33]=true,
}
-- 检查是否可以将此卡解放作为费用
function c23740893.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从游戏中除外
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选场上正面表示的「修验的妖社」怪兽
function c23740893.filter(c)
	return c:IsFaceup() and c:IsCode(27918963) and c:IsCanAddCounter(0x33,3)
end
-- 选择目标怪兽并设置操作信息
function c23740893.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c23740893.filter(chkc) end
	-- 判断是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c23740893.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要放置指示物的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23740893,0))  --"放置指示物"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c23740893.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，表示将放置3个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x33)
end
-- 给目标怪兽放置3个指示物
function c23740893.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x33,3)
	end
end
-- 判断是否可以进行通常召唤及额外召唤
function c23740893.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行通常召唤和额外召唤，并且未使用过此效果
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,23740893)==0 end
end
-- 设置额外召唤次数并注册标识效果
function c23740893.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此效果已使用则不重复发动
	if Duel.GetFlagEffect(tp,23740893)~=0 then return end
	-- 设置效果描述并注册额外召唤次数
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(23740893,1))  --"使用「妖仙兽 木魅」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为「妖仙兽」卡组
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb3))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册标识效果，防止此效果在同回合再次使用
	Duel.RegisterFlagEffect(tp,23740893,RESET_PHASE+PHASE_END,0,1)
end
