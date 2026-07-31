--捕食生成
-- 效果：
-- ①：把手卡的「捕食」卡任意数量给对方观看，以给人观看的数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：自己的「捕食植物」怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c72129804.initial_effect(c)
	-- ①：把手卡的「捕食」卡任意数量给对方观看，以给观看的数量的对方场上的表侧表示怪兽为对象才能发动。给那些怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
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
-- 手牌Cost过滤条件：未公开的「捕食」卡
function c72129804.cfilter(c)
	return c:IsSetCard(0xf3) and not c:IsPublic()
end
-- ①效果准备：展示手牌「捕食」卡，并选择相同数量可放置捕食指示物的对方表侧怪兽为对象
function c72129804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取手牌中所有未公开的「捕食」卡
	local hg=Duel.GetMatchingGroup(c72129804.cfilter,tp,LOCATION_HAND,0,e:GetHandler())
	-- 获取对方场上可放置捕食指示物的表侧怪兽数量上限
	local ct=Duel.GetTargetCount(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,0x1041,1)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	if chk==0 then return hg:GetCount()>0 and ct>0 end
	-- 提示玩家选择要展示给对方看的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local g=hg:Select(tp,1,ct,nil)
	-- 向对方玩家展示选中的「捕食」卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗混手牌
	Duel.ShuffleHand(tp)
	-- 提示玩家选择要放置指示物的表侧怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择与展示数量相同的对方表侧怪兽为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,g:GetCount(),g:GetCount(),nil,0x1041,1)
end
-- ①效果处理：给对象怪兽放置1个捕食指示物，并为其注册等级变1的效果
function c72129804.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍关联的效果对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=tg:GetFirst()
	while tc do
		if tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
			-- 给放置了捕食指示物的怪兽注册单体效果：有捕食指示物期间等级变为1星
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
-- 等级变更生效条件：怪兽身上仍有捕食指示物存在
function c72129804.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 代破过滤条件：己方场上被战斗破坏的表侧表示「捕食植物」怪兽
function c72129804.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f3) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 代破效果发动条件与准备：检查墓地此卡能否除外及是否存在被战破的「捕食植物」怪兽
function c72129804.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c72129804.repfilter,1,nil,tp) end
	-- 询问玩家是否发动墓地卡片代破效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代破价值评估：确定适用代替破坏的目标怪兽
function c72129804.repval(e,c)
	return c72129804.repfilter(c,e:GetHandlerPlayer())
end
-- 代破效果处理：将墓地的此卡除外以代替怪兽破坏
function c72129804.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的此卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
