--シンクロ・ガンナー
-- 效果：
-- 1回合1次，自己的主要阶段1才能发动。把自己场上表侧表示存在的1只同调怪兽从游戏中除外并给与对方基本分600分伤害。这个效果除外的怪兽在下次的自己的准备阶段时回到场上。
function c79796561.initial_effect(c)
	-- 1回合1次，自己的主要阶段1才能发动。把自己场上表侧表示存在的1只同调怪兽从游戏中除外并给与对方基本分600分伤害。这个效果除外的怪兽在下次的自己的准备阶段时回到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79796561,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c79796561.target)
	e1:SetOperation(c79796561.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且可以除外的同调怪兽
function c79796561.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemove()
end
-- 效果发动的目标选择与操作信息注册
function c79796561.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c79796561.filter(chkc) end
	-- 检查自己场上是否存在符合条件的、可作为效果对象的同调怪兽
	if chk==0 then return Duel.IsExistingTarget(c79796561.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示的同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79796561.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置除外操作信息，包含选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置伤害操作信息，给与对方玩家600分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果处理：将目标怪兽暂时除外，注册准备阶段返回场上的效果，并给与对方伤害
function c79796561.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍适用效果且表侧表示，并将其暂时除外
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 并给与对方基本分600分伤害。这个效果除外的怪兽在下次的自己的准备阶段时回到场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c79796561.retcon)
		e1:SetOperation(c79796561.retop)
		-- 注册用于在准备阶段将怪兽返回场上的全局延迟效果
		Duel.RegisterEffect(e1,tp)
		-- 给与对方玩家600分伤害
		Duel.Damage(1-tp,600,REASON_EFFECT)
	end
end
-- 延迟效果的触发条件：当前回合是自己的回合
function c79796561.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为发动效果的玩家
	return Duel.GetTurnPlayer()==tp
end
-- 延迟效果的处理：将除外的怪兽返回场上
function c79796561.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将被暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
