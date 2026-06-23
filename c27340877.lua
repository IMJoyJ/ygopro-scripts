--DNA定期健診
-- 效果：
-- 选择自己场上里侧表示存在的1只怪兽发动。对方宣言2个怪兽的属性。选择怪兽翻开确认是宣言属性的场合，对方从卡组抽2张卡。不是的场合，自己从卡组抽2张卡。
function c27340877.initial_effect(c)
	-- 效果设置：将此卡注册为发动时点效果，具有抽卡类别、取对象属性、自由时点，并设置其目标函数和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27340877.target)
	e1:SetOperation(c27340877.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标怪兽是否为里侧表示且具有种族
function c27340877.filter(c)
	return c:IsFacedown() and c:GetRace()~=0
end
-- 目标选择函数：判断是否满足选择目标的条件，包括目标为己方场上里侧表示的怪兽且具有种族，以及双方均可抽2张卡
function c27340877.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c27340877.filter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c27340877.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查双方是否可以抽2张卡
		and Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	-- 提示玩家选择里侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择满足条件的1只己方场上里侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,c27340877.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动函数：获取效果对象怪兽，若其存在且为里侧表示，则提示对方宣言属性并确认该怪兽属性
function c27340877.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 提示对方玩家选择宣言的属性
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让对方从所有属性中宣言2个属性
		local rc=Duel.AnnounceAttribute(1-tp,2,ATTRIBUTE_ALL)
		-- 向对方玩家展示目标怪兽的卡面
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsAttribute(rc) then
			-- 若目标怪兽属性与宣言属性一致，则对方从卡组抽2张卡
			Duel.Draw(1-tp,2,REASON_EFFECT)
		else
			-- 若目标怪兽属性与宣言属性不一致，则自己从卡组抽2张卡
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
