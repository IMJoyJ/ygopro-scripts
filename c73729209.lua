--スキル・サクセサー
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。直到这个回合的结束阶段时，选择怪兽的攻击力上升400。此外，可以把墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时上升800。这个效果在这张卡送去墓地的回合不能发动，自己回合才能发动。
function c73729209.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。直到这个回合的结束阶段时，选择怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c73729209.target)
	e1:SetOperation(c73729209.activate)
	e1:SetLabel(400)
	c:RegisterEffect(e1)
	-- 此外，可以把墓地存在的这张卡从游戏中除外，自己场上表侧表示存在的1只怪兽的攻击力直到这个回合的结束阶段时上升800。这个效果在这张卡送去墓地的回合不能发动，自己回合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73729209,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(c73729209.atkcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c73729209.target)
	e2:SetOperation(c73729209.activate)
	e2:SetLabel(800)
	c:RegisterEffect(e2)
end
-- 效果发动的对象选择与确认处理
function c73729209.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动阶段检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的对象怪兽的攻击力上升，直到回合结束阶段
function c73729209.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到这个回合的结束阶段时，选择怪兽的攻击力上升
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(e:GetLabel())
		tc:RegisterEffect(e1)
	end
end
-- 墓地效果的发动条件判定函数
function c73729209.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 必须满足：非送去墓地的回合、当前是自己回合、且在伤害步骤中非伤害计算后
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
