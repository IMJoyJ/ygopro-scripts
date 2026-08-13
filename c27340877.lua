--DNA定期健診
-- 效果：
-- 选择自己场上里侧表示存在的1只怪兽发动。对方宣言2个怪兽的属性。选择怪兽翻开确认是宣言属性的场合，对方从卡组抽2张卡。不是的场合，自己从卡组抽2张卡。
function c27340877.initial_effect(c)
	-- 选择自己场上里侧表示存在的1只怪兽发动。对方宣言2个怪兽的属性。选择怪兽翻开确认是宣言属性的场合，对方从卡组抽2张卡。不是的场合，自己从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27340877.target)
	e1:SetOperation(c27340877.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择里侧表示且种族不为0的怪兽，即确保对象为有明确种族的己方场上里侧怪兽。
function c27340877.filter(c)
	return c:IsFacedown() and c:GetRace()~=0
end
-- 效果发动的目标判定：先确认存在符合条件的里侧怪兽且双方都能抽2张；检查对象时确认所选卡满足取对象条件。
function c27340877.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27340877.filter(chkc) end
	-- 检查自己场上主要怪兽区是否存在至少1张满足filter条件的里侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c27340877.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且确认发动玩家和对方都允许通过效果抽2张卡，作为发动条件的一部分。
		and Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 给玩家tp显示“请选择里侧表示的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 从自己场上主要怪兽区选择1张里侧表示怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c27340877.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若对象卡仍与效果相关且仍为里侧表示，则让对方宣言2个属性，翻开对象确认；若对象属性为宣言属性则对方抽2张，否则自己抽2张。
function c27340877.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（此效果只选择1张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 向对方发送“请选择要宣言的属性”的提示消息。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 对方从全部属性中宣言2个属性，返回宣言属性组合值rc。
		local rc=Duel.AnnounceAttribute(1-tp,2,ATTRIBUTE_ALL)
		-- 将对象卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsAttribute(rc) then
			-- 确认对象是宣言属性时，对方抽2张卡。
			Duel.Draw(1-tp,2,REASON_EFFECT)
		else
			-- 确认对象不是宣言属性时，自己抽2张卡。
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
