--フレグランス・ストーム
-- 效果：
-- ①：以场上1只植物族怪兽为对象才能发动。那只植物族怪兽破坏，自己从卡组抽1张。那张抽到的卡是植物族怪兽的场合，可以再把那张卡给双方确认并让自己从卡组抽1张。
function c69584564.initial_effect(c)
	-- ①：以场上1只植物族怪兽为对象才能发动。那只植物族怪兽破坏，自己从卡组抽1张。那张抽到的卡是植物族怪兽的场合，可以再把那张卡给双方确认并让自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c69584564.target)
	e1:SetOperation(c69584564.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示的植物族怪兽
function c69584564.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果发动时的目标选择与合法性检测
function c69584564.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c69584564.filter(chkc) end
	-- 检查发动玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在可以作为对象的植物族怪兽
		and Duel.IsExistingTarget(c69584564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只植物族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c69584564.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果包含破坏选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息，表明该效果包含抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数，处理破坏、抽卡以及后续的确认并再抽卡
function c69584564.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，并将其破坏
	if tc:IsRelateToEffect(e) and c69584564.filter(tc) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 破坏成功后，发动玩家从卡组抽1张卡
		local ct=Duel.Draw(tp,1,REASON_EFFECT)
		if ct==0 then return end
		-- 获取刚才通过抽卡操作加入手卡的卡片
		local dc=Duel.GetOperatedGroup():GetFirst()
		-- 检查抽到的卡是否为植物族怪兽，且玩家是否仍能继续抽卡
		if dc:IsRace(RACE_PLANT) and Duel.IsPlayerCanDraw(tp,1)
			-- 询问玩家是否选择发动“给双方确认并再抽1张”的效果
			and Duel.SelectYesNo(tp,aux.Stringid(69584564,0)) then  --"是否要给对方确认抽到的卡？"
			-- 中断当前效果处理，使后续的确认和抽卡不与前面的抽卡视为同时处理
			Duel.BreakEffect()
			-- 将抽到的植物族怪兽给对方玩家确认
			Duel.ConfirmCards(1-tp,dc)
			-- 确认后，发动玩家再从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
			-- 重新洗切发动玩家的手卡
			Duel.ShuffleHand(tp)
		end
	end
end
