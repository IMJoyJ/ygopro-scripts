--アンデット・ネクロナイズ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上有5星以上的不死族怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c38363525.initial_effect(c)
	-- ①：场上有5星以上的不死族怪兽存在的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38363525,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38363525)
	e1:SetCondition(c38363525.condition)
	e1:SetTarget(c38363525.target)
	e1:SetOperation(c38363525.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38363525,1))  --"在自己场上盖放"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38363525)
	e2:SetTarget(c38363525.settg)
	e2:SetOperation(c38363525.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在5星以上的不死族怪兽
function c38363525.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
end
-- 判断场上有5星以上的不死族怪兽存在的条件
function c38363525.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上有5星以上的不死族怪兽存在的条件
	return Duel.IsExistingMatchingCard(c38363525.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 设置效果目标，选择对方场上的怪兽作为对象
function c38363525.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查是否能选择对方场上的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上的怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，记录将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理效果的发动，使目标怪兽的控制权转移
function c38363525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽的控制权转移给玩家，直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
-- 过滤函数，用于判断除外区是否存在符合条件的不死族怪兽
function c38363525.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 设置效果目标，检查是否可以发动效果
function c38363525.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查除外区是否存在符合条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c38363525.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置效果操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，将除外的不死族怪兽送回卡组并盖放此卡
function c38363525.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外区的不死族怪兽作为对象
	local g=Duel.SelectMatchingCard(tp,c38363525.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 显示所选的卡被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡送回卡组并盖放此卡，若成功则设置效果
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 设置效果，使此卡从场上离开时被除外
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end
