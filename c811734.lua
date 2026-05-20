--DDDの契約変更
-- 效果：
-- ①：对方怪兽的攻击宣言时可以从以下效果选择1个发动。
-- ●选自己墓地1只「DDD」怪兽除外。攻击怪兽的攻击力下降这个效果除外的怪兽的攻击力数值。
-- ●从卡组把1只4星以下的「DD」灵摆怪兽加入手卡。
function c811734.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时可以从以下效果选择1个发动。●选自己墓地1只「DDD」怪兽除外。攻击怪兽的攻击力下降这个效果除外的怪兽的攻击力数值。●从卡组把1只4星以下的「DD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c811734.condition)
	e1:SetTarget(c811734.target)
	e1:SetOperation(c811734.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件（对方怪兽攻击宣言时）
function c811734.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤自己墓地中攻击力大于0且可以除外的「DDD」怪兽
function c811734.atkfilter(c)
	return c:IsSetCard(0x10af) and c:GetAttack()>0 and c:IsAbleToRemove()
end
-- 过滤卡组中4星以下且可以加入手牌的「DD」灵摆怪兽
function c811734.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0xaf) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与效果分支处理
function c811734.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足条件的「DDD」怪兽（分支1是否可行）
	local b1=Duel.IsExistingMatchingCard(c811734.atkfilter,tp,LOCATION_GRAVE,0,1,nil)
	-- 检查自己卡组是否存在满足条件的「DD」灵摆怪兽（分支2是否可行）
	local b2=Duel.IsExistingMatchingCard(c811734.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支均可行时，让玩家选择其中一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(811734,0),aux.Stringid(811734,1))  --"怪兽除外/卡组检索"
	elseif b1 then
		-- 仅分支1（除外墓地怪兽）可行时，强制选择分支1
		op=Duel.SelectOption(tp,aux.Stringid(811734,0))  --"怪兽除外"
	-- 仅分支2（卡组检索）可行时，强制选择分支2
	else op=Duel.SelectOption(tp,aux.Stringid(811734,1))+1 end  --"卡组检索"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_REMOVE)
		-- 设置连锁处理信息：从自己墓地除外1张卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁处理信息：从卡组将1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理的执行函数
function c811734.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己墓地选择1只满足条件的「DDD」怪兽
		local g=Duel.SelectMatchingCard(tp,c811734.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()==0 then return end
		local atk=g:GetFirst():GetAttack()
		-- 获取当前进行攻击宣言的怪兽
		local tc=Duel.GetAttacker()
		-- 成功除外选中的怪兽，且攻击怪兽仍在场上表侧表示存在时
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsRelateToBattle() and tc:IsFaceup() then
			-- 攻击怪兽的攻击力下降这个效果除外的怪兽的攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	else
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只满足条件的「DD」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c811734.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
