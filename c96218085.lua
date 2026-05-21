--中央突破
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「六武众」的怪兽发动。这个回合的战斗阶段中，选择怪兽战斗破坏对方怪兽的场合，自己场上存在的「大将军 紫炎」或者名字带有「六武众」的怪兽可以直接攻击对方玩家。
function c96218085.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「六武众」的怪兽发动。这个回合的战斗阶段中，选择怪兽战斗破坏对方怪兽的场合，自己场上存在的「大将军 紫炎」或者名字带有「六武众」的怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c96218085.condition)
	e1:SetTarget(c96218085.target)
	e1:SetOperation(c96218085.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：限制在主要阶段2之前发动（确保在战斗阶段前或战斗阶段中生效）。
function c96218085.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否在主要阶段2之前。
	return Duel.GetCurrentPhase()<PHASE_MAIN2
end
-- 过滤条件：自己场上表侧表示的「六武众」怪兽。
function c96218085.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 效果发动时的靶向处理：选择自己场上1只表侧表示的「六武众」怪兽作为对象。
function c96218085.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c96218085.filter(chkc) end
	-- 判定自己场上是否存在符合条件的「六武众」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c96218085.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「六武众」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c96218085.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为作为对象的怪兽注册一个“战斗破坏对方怪兽时触发”的单次效果。
function c96218085.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择怪兽战斗破坏对方怪兽的场合，自己场上存在的「大将军 紫炎」或者名字带有「六武众」的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOperation(c96218085.desop)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「大将军 紫炎」或「六武众」怪兽。
function c96218085.filter2(c)
	return c:IsFaceup() and (c:IsSetCard(0x103d) or c:IsCode(63176202))
end
-- 战斗破坏怪兽时的效果处理：使自己场上所有的「大将军 紫炎」和「六武众」怪兽在这个回合可以直接攻击。
function c96218085.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「大将军 紫炎」以及「六武众」怪兽。
	local g=Duel.GetMatchingGroup(c96218085.filter2,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上存在的「大将军 紫炎」或者名字带有「六武众」的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
