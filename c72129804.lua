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
-- 过滤手牌中没有公开的「捕食」卡
function c72129804.cfilter(c)
	return c:IsSetCard(0xf3) and not c:IsPublic()
end
-- 选择手牌的「捕食」卡向对方展示，并选择对方场上等量的表侧表示怪兽作为对象
function c72129804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取手牌中可展示的「捕食」卡
	local hg=Duel.GetMatchingGroup(c72129804.cfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 获取对方场上可以放置捕食指示物的怪兽数量
	local ct=Duel.GetTargetCount(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1041,1)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	if chk==0 then return hg:GetCount()>0 and ct>0 end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local g=hg:Select(tp,1,ct,nil)
	-- 向对方展示选择的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手牌
	Duel.ShuffleHand(tp)
	-- 提示玩家选择表侧表示的卡作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上等量的可以放置指示物的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,g:GetCount(),g:GetCount(),nil,0x1041,1)
end
-- 为对象怪兽各放置1个捕食指示物，并使其中2星以上的怪兽等级变成1星
function c72129804.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象中与效果相关联的卡
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
-- 检查该怪兽是否有捕食指示物放置
function c72129804.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 检查怪兽是否为自己场上的「捕食植物」怪兽且被战斗破坏
function c72129804.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f3) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 检查墓地的此卡是否能除外，并且场上是否有满足代替破坏条件的怪兽
function c72129804.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c72129804.repfilter,1,nil,tp) end
	-- 询问玩家是否发动效果代替破坏
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 获取要代替破坏的卡
function c72129804.repval(e,c)
	return c72129804.repfilter(c,e:GetHandlerPlayer())
end
-- 把墓地的这张卡除外
function c72129804.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 把此卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
