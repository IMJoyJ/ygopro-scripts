--借カラクリ蔵
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「机巧」的怪兽发动。从自己卡组把1只4星以下的名字带有「机巧」的怪兽加入手卡，选择的怪兽的表示形式变更。
function c80204957.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「机巧」的怪兽发动。从自己卡组把1只4星以下的名字带有「机巧」的怪兽加入手卡，选择的怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c80204957.target)
	e1:SetOperation(c80204957.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：卡组中4星以下的名字带有「机巧」且能加入手牌的怪兽
function c80204957.filter1(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11) and c:IsAbleToHand()
end
-- 过滤函数：场上表侧表示、名字带有「机巧」且能改变表示形式的怪兽
function c80204957.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x11) and c:IsCanChangePosition()
end
-- 效果发动时的目标选择与合法性检查
function c80204957.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c80204957.filter2(chkc) end
	-- 检查卡组中是否存在至少1只满足条件的「机巧」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80204957.filter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己场上是否存在至少1只可作为对象的表侧表示「机巧」怪兽
		and Duel.IsExistingTarget(c80204957.filter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只表侧表示的「机巧」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80204957.filter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息：改变所选择怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理的执行函数
function c80204957.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足条件的「机巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c80204957.filter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 获取发动时选择的作为对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽的表示形式变更（表侧攻击表示与表侧守备表示互相变更）
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
		-- 将选中的「机巧」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
