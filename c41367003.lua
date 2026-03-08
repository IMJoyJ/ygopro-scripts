--ドロー・マッスル
-- 效果：
-- 「抽卡肌肉」在1回合只能发动1张。
-- ①：以自己场上1只守备力1000以下的表侧守备表示怪兽为对象才能发动。自己从卡组抽1张。那只怪兽在这个回合不会被战斗破坏。
function c41367003.initial_effect(c)
	-- 效果原文内容：「抽卡肌肉」在1回合只能发动1张。
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
-- 效果作用：筛选场上表侧守备表示且守备力不超过1000的怪兽
function c41367003.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsDefenseBelow(1000)
end
-- 效果作用：判断是否可以发动此效果，包括玩家能否抽卡和场上是否存在符合条件的怪兽
function c41367003.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41367003.filter(chkc,e,tp) end
	-- 效果作用：判断玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 效果作用：判断场上是否存在符合条件的怪兽作为对象
		and Duel.IsExistingTarget(c41367003.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择表侧守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)  --"请选择表侧守备表示的怪兽"
	-- 效果作用：选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c41367003.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 效果作用：设置效果处理信息，表明将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果作用：处理效果的发动，包括抽卡和给对象怪兽添加不被战斗破坏的效果
function c41367003.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果选择的怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断抽卡是否成功且对象怪兽仍然在场上
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		-- 效果原文内容：那只怪兽在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
