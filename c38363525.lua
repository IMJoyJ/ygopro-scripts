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
-- 过滤函数：判断怪兽是否为表侧表示、等级5以上且种族为不死族，用于检查场上是否存在满足①发动条件的怪兽。
function c38363525.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
end
-- ①效果的发动条件：检查我方或对方场上是否存在至少1只满足cfilter的表侧表示5星以上不死族怪兽，存在则满足发动条件。
function c38363525.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回布尔值：场上是否存在至少1只等级5以上的表侧不死族怪兽。
	return Duel.IsExistingMatchingCard(c38363525.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动时处理：先进行取对象合法性判定，然后提示玩家选择对方场上1只可改变控制权的怪兽作为对象，并设置操作信息为改变控制权。
function c38363525.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 效果发动前检查：确认对方场上是否存在至少1只可改变控制权的怪兽作为合法对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家发送选卡提示，提示内容为“请选择要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只可改变控制权的怪兽作为效果对象，并自动记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：该效果属于改变控制权效果，处理对象为已选择的怪兽组g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ①效果处理时的操作：取出效果处理阶段仍与效果关联的对象怪兽，若对象合法则取得其控制权直到结束阶段。
function c38363525.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张对象卡，即被选择控制权的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽的控制权转移给当前玩家tp，持续到结束阶段（PHASE_END）并重置1次。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
-- 过滤函数：判断除外区的卡是否为表侧表示、不死族且可以返回卡组，用于②效果选择返回卡组的不死族怪兽。
function c38363525.setfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- ②效果的发动条件与目标判定：此卡在墓地且可以盖放，并且除外区存在至少1只满足setfilter的不死族怪兽。
function c38363525.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 发动条件后半部分：确认除外区存在至少1只满足setfilter（表侧不死族且可回卡组）的自己的怪兽。
		and Duel.IsExistingMatchingCard(c38363525.setfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：该效果处理时此卡会离开墓地（涉及墓地相关效果判定），处理对象为此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理时的操作：选择除外区1只自己的不死族怪兽返回卡组并洗牌，若返回成功且此卡仍在墓地且可盖放，则将此卡盖放在自己场上，并附加“从场上离开时除外”的效果。
function c38363525.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选卡提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己的除外区选择1只满足setfilter表侧不死族且可回卡组的怪兽。
	local g=Duel.SelectMatchingCard(tp,c38363525.setfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 手动显示所选卡片的选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选中的怪兽以效果原因返回卡组并洗牌；同时检查此卡是否仍与效果关联，若关联且能盖放，则将此卡盖放在自己场上，返回盖放成功数。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
			-- 这个效果盖放的这张卡从场上离开的场合除外。
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
