--黒光りするG
-- 效果：
-- 对方场上有1只同调怪兽特殊召唤时，把自己墓地存在的这张卡从游戏中除外发动。那1只同调怪兽破坏。
function c94081496.initial_effect(c)
	-- 对方场上有1只同调怪兽特殊召唤时，把自己墓地存在的这张卡从游戏中除外发动。那1只同调怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94081496,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c94081496.target)
	e1:SetOperation(c94081496.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件和效果对象，确认特殊召唤的怪兽数量为1、在对方场上表侧表示存在、是同调怪兽且可以成为效果对象
function c94081496.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if chkc then return chkc==tc end
	if chk==0 then return eg:GetCount()==1 and tc:IsFaceup() and tc:IsType(TYPE_SYNCHRO) and tc:IsOnField()
		and tc:IsControler(1-tp) and tc:IsCanBeEffectTarget(e) end
	-- 将特殊召唤的怪兽设为效果处理的对象
	Duel.SetTargetCard(eg)
	-- 设置效果处理信息，表示该效果包含破坏1只目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理时，若目标怪兽仍表侧表示存在且与效果有关联，则将其破坏
function c94081496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
