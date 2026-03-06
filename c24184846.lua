--BK リベージ・ガードナー
-- 效果：
-- 把手卡或者墓地的这张卡从游戏中除外，选择自己场上1只名字带有「燃烧拳击手」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。
function c24184846.initial_effect(c)
	-- 把手卡或者墓地的这张卡从游戏中除外，选择自己场上1只名字带有「燃烧拳击手」的怪兽才能发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24184846,0))  --"除外"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c24184846.rmcost)
	e1:SetTarget(c24184846.rmtg)
	e1:SetOperation(c24184846.rmop)
	c:RegisterEffect(e1)
end
-- 将自身从游戏中除外作为费用
function c24184846.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从游戏中除外作为费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤场上正面表示且名字带有「燃烧拳击手」的怪兽
function c24184846.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsAbleToRemove()
end
-- 选择场上正面表示且名字带有「燃烧拳击手」的怪兽作为对象
function c24184846.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24184846.filter(chkc) end
	-- 确认场上是否存在名字带有「燃烧拳击手」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c24184846.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c24184846.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，确定要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果，将目标怪兽除外并设置返回机制
function c24184846.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽暂时除外
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		-- 创建一个在下次准备阶段时将目标怪兽返回场上的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c24184846.retcon)
		e1:SetOperation(c24184846.retop)
		-- 判断是否为自己的抽卡阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetLabel(0)
		else
			-- 记录当前回合数作为标签
			e1:SetLabel(Duel.GetTurnCount())
		end
		-- 将效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否为自己的回合且回合数与标签不同
function c24184846.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合且回合数与标签不同
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 将目标怪兽返回场上
function c24184846.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
