--捕食生成
-- 效果：
-- ①：把手卡的「捕食」卡任意数量给对方观看，以给人观看的数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：自己的「捕食植物」怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c72129804.initial_effect(c)
	-- ①：把手卡的「捕食」卡任意数量给对方观看，以给人观看的数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c72129804.target)
	e1:SetOperation(c72129804.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「捕食植物」怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c72129804.reptg)
	e2:SetValue(c72129804.repval)
	e2:SetOperation(c72129804.repop)
	c:RegisterEffect(e2)
end
c72129804.mentioned_counter={
	[0x1041]=true,
}
-- Cost过滤条件：手牌中未公开的「捕食」卡
function c72129804.cfilter(c)
	return c:IsSetCard(0xf3) and not c:IsPublic()
end
-- ①效果发动准备：给对方确认手牌「捕食」卡并选择等量对方怪兽为对象
function c72129804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取手牌中所有符合条件的「捕食」卡
	local hg=Duel.GetMatchingGroup(c72129804.cfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 计算对方场上可放置捕食指示物的怪兽数量（作为选择手牌卡片数量的上限）
	local ct=Duel.GetTargetCount(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1041,1)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	if chk==0 then return hg:GetCount()>0 and ct>0 end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local g=hg:Select(tp,1,ct,nil)
	-- 向对方展示选中的手牌「捕食」卡
	Duel.ConfirmCards(1-tp,g)
	-- 将手牌洗混
	Duel.ShuffleHand(tp)
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择与展示数量相等的对方场上怪兽作为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,g:GetCount(),g:GetCount(),nil,0x1041,1)
end
-- ①效果处理：给对象怪兽放置捕食指示物并赋予变成1星的持续效果
function c72129804.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与此效果关联的有效对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		if tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
			-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c72129804.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
		tc=tg:GetNext()
	end
end
-- 等级变更条件：该怪兽身上存在至少1个捕食指示物
function c72129804.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 代替破坏过滤条件：自己场上表侧表示被战斗破坏的「捕食植物」怪兽
function c72129804.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f3) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- ②效果代替破坏发动条件检查及询问是否代替
function c72129804.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c72129804.repfilter,1,nil,tp) end
	-- 询问玩家是否发动墓地代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确认需要代替破坏的目标怪兽符合条件
function c72129804.repval(e,c)
	return c72129804.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果代替破坏处理：把墓地的这张卡除外
function c72129804.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的此卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
