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
-- 发动代价判定及执行：先检查手卡/墓地的这张卡能否作为代价除外，若能则将其作为代价除外。
function c24184846.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示从手卡/墓地除外，作为效果的发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义可选对象过滤条件：自己场上的表侧表示怪兽、卡名属于「燃烧拳击手」系列、且能够被除外。
function c24184846.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择：从自己场上选择1只符合条件的「燃烧拳击手」怪兽作为对象，并设置除外相关的操作信息。
function c24184846.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24184846.filter(chkc) end
	-- 发动时合法性检查：确认自己场上是否存在至少1只可供选择的目标怪兽。
	if chk==0 then return Duel.IsExistingTarget(c24184846.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示信息，提示玩家从自己场上选择要除外的「燃烧拳击手」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只符合条件的「燃烧拳击手」怪兽，并将其设为效果处理时的对象。
	local g=Duel.SelectTarget(tp,c24184846.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将本次操作信息登记为‘除外’（CATEGORY_REMOVE），对象为已选择的1张卡，供后续效果处理和连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：将对象怪兽暂时除外（REASON_TEMPORARY），并注册一个在下次自己的准备阶段将其归还的持续效果。
function c24184846.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽从游戏中暂时除外；若除外失败则结束本次效果处理。
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		-- 选择的怪兽直到下次的自己的准备阶段时从游戏中除外。（对应归还的持续效果）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c24184846.retcon)
		e1:SetOperation(c24184846.retop)
		-- 判断当前是否处于自己的抽卡阶段；若是，则使用特殊标记（0）来保证紧接着的自己的准备阶段就会执行归还。
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e1:SetLabel(0)
		else
			-- 记录当前回合数作为标签，用于判断‘下次自己的准备阶段’是否已到达。
			e1:SetLabel(Duel.GetTurnCount())
		end
		-- 将等待归还的持续效果注册到场上，使其在满足条件时自动执行归还。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 归还触发条件判定：仅在自己的准备阶段且已经到达‘下次’（回合数不等于记录的标签）时允许归还。
function c24184846.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真表示当前是自己回合的准备阶段，并且不是发动效果的那一回合，即到达了应当归还的时点。
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 归还处理：将被暂时除外的对象怪兽返回场上，并重置该持续效果，使其不再作用。
function c24184846.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的对象怪兽以离场前的表示形式返回场上。
	Duel.ReturnToField(e:GetLabelObject())
	e:Reset()
end
