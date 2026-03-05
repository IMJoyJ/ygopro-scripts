--闇の誘惑
-- 效果：
-- ①：自己抽2张。那之后，手卡有暗属性怪兽存在的场合，选那之内的1只除外。不存在的场合，自己手卡全部送去墓地。
function c1475311.initial_effect(c)
	-- ①：自己抽2张。那之后，手卡有暗属性怪兽存在的场合，选那之内的1只除外。不存在的场合，自己手卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c1475311.target)
	e1:SetOperation(c1475311.activate)
	c:RegisterEffect(e1)
end
-- 效果处理函数target的定义
function c1475311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果（能除外卡且能抽2张卡）
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置效果操作信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数activate的定义
function c1475311.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，若未抽到卡则返回
	if Duel.Draw(p,d,REASON_EFFECT)<=0 then return end
	-- 中断当前效果处理，使后续处理视为错时点
	Duel.BreakEffect()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的暗属性怪兽（手卡中）
	local g=Duel.SelectMatchingCard(p,Card.IsAttribute,p,LOCATION_HAND,0,1,1,nil,ATTRIBUTE_DARK)
	-- 洗切当前玩家的手牌
	Duel.ShuffleHand(p)
	local tg=g:GetFirst()
	if tg then
		-- 尝试将选中的卡除外，若失败则确认对方查看该卡并洗切手牌
		if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)==0 then
			-- 向对方玩家确认该卡
			Duel.ConfirmCards(1-p,tg)
			-- 再次洗切当前玩家的手牌
			Duel.ShuffleHand(p)
		end
	else
		-- 获取当前玩家手牌组
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将当前玩家所有手牌送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
