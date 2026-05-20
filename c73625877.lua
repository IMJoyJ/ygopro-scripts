--タイム・エスケーパー
-- 效果：
-- 把这张卡从手卡丢弃，选择自己场上表侧表示存在的1只念动力族怪兽发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。
function c73625877.initial_effect(c)
	-- 把这张卡从手卡丢弃，选择自己场上表侧表示存在的1只念动力族怪兽发动。选择的怪兽直到下次的自己的准备阶段时从游戏中除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73625877,0))  --"除外"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c73625877.rmcost)
	e1:SetTarget(c73625877.rmtg)
	e1:SetOperation(c73625877.rmop)
	c:RegisterEffect(e1)
end
-- 效果发动代价（Cost）的处理函数：检测并把手牌的这张卡丢弃
function c73625877.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己场上表侧表示的、可以被除外的念动力族怪兽
function c73625877.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 效果发动目标（Target）的处理函数：选择自己场上1只表侧表示的念动力族怪兽作为对象
function c73625877.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c73625877.filter(chkc) end
	-- 检查自己场上是否存在符合条件的念动力族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c73625877.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示的念动力族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73625877.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果运行（Operation）的处理函数：将对象怪兽暂时除外，并注册一个在下次自己准备阶段将其返回场上的延迟效果
function c73625877.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因暂时除外，若除外失败则结束处理
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		-- 选择的怪兽直到下次的自己的准备阶段时从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c73625877.retcon)
		e1:SetOperation(c73625877.retop)
		-- 判断当前是否为自己的抽卡阶段（若是，则在接下来的准备阶段就会立刻返回，因此将Label设为0以避开回合数校验）
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetLabel(0)
		else
			-- 将当前回合数记录在Label中，用于后续判断是否已经过了当前回合
			e1:SetLabel(Duel.GetTurnCount())
		end
		-- 注册该全局延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟效果的触发条件：必须是自己的回合，且不能是除外发生的那一个回合（除非是在抽卡阶段除外）
function c73625877.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且当前回合数不等于除外发生时的回合数（确保至少跨越到下一个自己的准备阶段）
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 延迟效果的运行函数：将除外的怪兽返回场上，并重置（销毁）该延迟效果
function c73625877.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
