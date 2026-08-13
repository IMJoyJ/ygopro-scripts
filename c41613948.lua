--D-HERO デビルガイ
-- 效果：
-- 这张卡在自己场上表侧攻击表示存在的场合，1回合只有1次，可以把1只对方怪兽从游戏中除外。使用这个效果的玩家在这个回合不能进行战斗。这个效果除外的怪兽在第2次自己的准备阶段时以相同的表示形式回到对方场上。
function c41613948.initial_effect(c)
	-- 这个卡名的效果发动的回合，自己不能攻击宣言。①：1回合1次，以对方场上1只怪兽为对象才能发动（这个效果在这张卡在自己场上表侧攻击表示存在的场合才能发动和处理）。那只对方怪兽直到发动后第2次的自己准备阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41613948,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c41613948.condition)
	e1:SetCost(c41613948.cost)
	e1:SetTarget(c41613948.target)
	e1:SetOperation(c41613948.operation)
	c:RegisterEffect(e1)
end
-- 效果发动和处理时，必须满足此卡在自己场上表侧攻击表示存在；若条件不满足则不能发动或效果不处理。
function c41613948.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 作为发动代价，确认本回合自己尚未进行过攻击宣言，并在发动后给己方玩家施加本回合不能进行攻击宣言的限制（誓约效果，直到回合结束）。
function c41613948.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价是否满足：本回合自己攻击宣言次数为0（即本回合尚未攻击过）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 这个卡名的效果发动的回合，自己不能攻击宣言。①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽直到发动后第2次的自己准备阶段除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将刚创建的‘本回合不能进行攻击宣言’的永续效果注册给发动方玩家，在该回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- 发动时判定合法对象并选择对象：选择对方场上1只可除外的怪兽作为效果对象，并设置连锁信息为除外。
function c41613948.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动条件检查：对方场上是否存在至少1只可以作为对象且能被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择卡片的提示信息‘请选择要除外的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1只满足可除外条件的怪兽，并将其登记为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁的效果分类为除外，对象为选择的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：在发动卡仍表侧攻击表示且与效果关联、对象仍与效果关联时，将对象怪兽暂时除外，并为其注册在第2次自己准备阶段返回场上的处理效果。
function c41613948.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 确认发动怪兽仍位于场上且表侧攻击表示、对象怪兽仍与效果关联；满足后将对象怪兽以暂时除外形式除外（若除外成功则继续设置返回效果）。
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那只对方怪兽直到发动后第2次的自己准备阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e1:SetCountLimit(1)
		e1:SetCondition(c41613948.retcon)
		e1:SetOperation(c41613948.retop)
		e1:SetLabel(1)
		e1:SetLabelObject(tc)
		-- 将第2次自己准备阶段时使除外怪兽返回场上的诱发效果注册给发动方玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 该返回效果的触发条件：只有发动者的准备阶段（且是第2次自己准备阶段）才会触发。
function c41613948.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否就是发动效果的玩家（只有自己的准备阶段时该值为真）。
	return tp==Duel.GetTurnPlayer()
end
-- 返回效果的发动处理：第一次准备阶段仅将标记置0，第二次准备阶段时将暂时除外的对象怪兽返回场上。
function c41613948.retop(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetLabel()
	if t==1 then e:SetLabel(0)
	-- 第二次准备阶段时，将登记在效果LabelObject中的对象怪兽以离场前的表示形式返回对方场上。
	else Duel.ReturnToField(e:GetLabelObject())	end
end
