--闇の誘惑
-- 效果：
-- ①：自己抽2张。那之后，手卡有暗属性怪兽存在的场合，选那之内的1只除外。不存在的场合，自己手卡全部送去墓地。
function c1475311.initial_effect(c)
	-- ①：自己抽2张。那之后，手卡有暗属性怪兽存在的场合，选那之内的1只除外。不存在的场合，自己手卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1475311.target)
	e1:SetOperation(c1475311.activate)
	c:RegisterEffect(e1)
end
-- 设置效果发动的可行性检查、目标玩家以及抽卡参数，并注册抽卡操作信息
function c1475311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否能够执行除外操作以及是否能够效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的参数值（抽卡数量）为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行抽2张卡，并根据手卡中是否有暗属性怪兽选择将其中1只除外或将全部手卡送去墓地
function c1475311.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的对象玩家及参数值（即抽卡的目标玩家与数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令对象玩家因效果抽卡，若实际抽卡数小于或等于0则直接结束
	if Duel.Draw(p,d,REASON_EFFECT)<=0 then return end
	-- 中断当前效果，使之后的处理与抽卡不视为同时进行
	Duel.BreakEffect()
	-- 提示玩家选择需要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1只暗属性怪兽
	local g=Duel.SelectMatchingCard(p,Card.IsAttribute,p,LOCATION_HAND,0,1,1,nil,ATTRIBUTE_DARK)
	-- 重新洗切玩家手卡
	Duel.ShuffleHand(p)
	local tg=g:GetFirst()
	if tg then
		-- 尝试以表侧表示除外选择的暗属性怪兽，并判断是否除外失败
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
			-- 如果除外失败，向对方玩家展示该卡片以确认
			Duel.ConfirmCards(1-p,tg)
			-- 再次洗切该玩家的手卡
			Duel.ShuffleHand(p)
		end
	else
		-- 获取该玩家手卡的全部卡片组
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将该玩家的全部手卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
