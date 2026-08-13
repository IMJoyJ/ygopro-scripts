--ドロー・マッスル
-- 效果：
-- 「抽卡肌肉」在1回合只能发动1张。
-- ①：以自己场上1只守备力1000以下的表侧守备表示怪兽为对象才能发动。自己从卡组抽1张。那只怪兽在这个回合不会被战斗破坏。
function c41367003.initial_effect(c)
	-- 「抽卡肌肉」在1回合只能发动1张。①：以自己场上1只守备力1000以下的表侧守备表示怪兽为对象才能发动。自己从卡组抽1张。那只怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,41367003+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41367003.target)
	e1:SetOperation(c41367003.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为对象的怪兽：必须是表侧守备表示且守备力1000以下的怪兽。
function c41367003.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsDefenseBelow(1000)
end
-- 目标处理函数：若chkc存在，则校验其是否仍为自己场上表侧守备表示且守备力1000以下的怪兽；若chk==0，则进行发动合法性检查。
function c41367003.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41367003.filter(chkc,e,tp) end
	-- 发动合法性检查：确认玩家tp可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 同时确认自己场上存在至少1只满足条件的怪兽，可作为此效果的对象。
		and Duel.IsExistingTarget(c41367003.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示选择提示消息，要求玩家选择表侧守备表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)  --"请选择表侧守备表示的怪兽"
	-- 让玩家tp从自己主要怪兽区域选择1只符合条件的表侧守备表示怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c41367003.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本连锁将进行抽卡（CATEGORY_DRAW），预定向玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：抽1张卡，若抽卡成功且对象怪兽仍与此效果关联，则给该对象附加“不会被战斗破坏”的效果，持续到回合结束。
function c41367003.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 执行抽卡1张（REASON_EFFECT），若实际抽卡数不为0且对象怪兽仍与此效果关联，则继续执行后续赋予抗性效果。
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 对应效果原文：那只怪兽在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
