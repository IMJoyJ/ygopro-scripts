--BF－下弦のサルンガ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果在决斗中只能使用1次。
-- ①：场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方回合，自己场上有「黑羽」同调怪兽存在的场合，把墓地的这张卡除外，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c54594017.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场上有攻击力2000以上的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,54594017+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c54594017.spcon)
	c:RegisterEffect(e1)
	-- ②的效果在决斗中只能使用1次。②：自己·对方回合，自己场上有「黑羽」同调怪兽存在的场合，把墓地的这张卡除外，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,54594018+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c54594017.descon)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c54594017.destg)
	e2:SetOperation(c54594017.desop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示且攻击力在2000以上的怪兽
function c54594017.filter(c)
	return c:IsAttackAbove(2000) and c:IsFaceup()
end
-- 自身特殊召唤规则的判定条件（场上有可用怪兽区域，且场上有攻击力2000以上的怪兽存在）
function c54594017.spcon(e,c)
	if c==nil then return true end
	-- 检查自身怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方场上是否存在至少1只表侧表示且攻击力在2000以上的怪兽
		and Duel.IsExistingMatchingCard(c54594017.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤自己场上表侧表示的「黑羽」同调怪兽
function c54594017.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)
end
-- 破坏效果的发动条件（自己场上存在「黑羽」同调怪兽）
function c54594017.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「黑羽」同调怪兽
	return Duel.IsExistingMatchingCard(c54594017.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 破坏效果的目标选择与发动准备（检查合法对象、提示玩家选择、设置效果处理信息）
function c54594017.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1张表侧表示的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表明此效果包含“破坏”分类，涉及卡片为选择的对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理（获取对象卡，若其仍满足条件则将其破坏）
function c54594017.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
