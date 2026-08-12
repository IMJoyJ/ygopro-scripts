--電送擬人エレキネシス
-- 效果：
-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只怪兽为对象才能发动。那只对方怪兽的位置向其他的对方的主要怪兽区域移动。这个效果在对方回合也能发动。
function c88392300.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地，以对方场上1只怪兽为对象才能发动。那只对方怪兽的位置向其他的对方的主要怪兽区域移动。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c88392300.seqcost)
	e2:SetTarget(c88392300.seqtg)
	e2:SetOperation(c88392300.seqop)
	c:RegisterEffect(e2)
end
-- 定义效果①的Cost：检查自身是否能作为Cost送去墓地，并执行送去墓地的操作
function c88392300.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义效果①的Target：检查是否能选择合法的对象，并进行对象选择
function c88392300.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动时，检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil)
		-- 并且对方的主要怪兽区域有可用的空格
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 在客户端显示选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88392300,0))  --"请选择要移动位置的怪兽"
	-- 选择对方场上的1只怪兽作为效果的对象
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果①的Operation：执行将对象怪兽移动到其他主要怪兽区域的操作
function c88392300.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp)
		-- 如果对方的主要怪兽区域没有可用的空格，则不处理效果
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 在客户端显示选择要移动到的位置的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择1个可用的对方主要怪兽区域的空格
	local s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	local nseq=math.log(bit.rshift(s,16),2)
	-- 将对象怪兽移动到选择的怪兽区域
	Duel.MoveSequence(tc,nseq)
end
