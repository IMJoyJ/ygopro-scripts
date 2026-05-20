--アンデット・ストラグル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1只不死族怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力上升1000或者下降1000。
-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c65357623.initial_effect(c)
	-- ①：以场上1只不死族怪兽为对象才能发动。直到回合结束时，那只怪兽的攻击力上升1000或者下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(65357623,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前以外的时机（允许在伤害步骤发动，但不能在伤害计算后发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c65357623.target)
	e1:SetOperation(c65357623.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。选除外的1只自己的不死族怪兽回到卡组，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetDescription(aux.Stringid(65357623,3))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,65357623)
	e2:SetTarget(c65357623.settg)
	e2:SetOperation(c65357623.setop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的不死族怪兽
function c65357623.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 效果①的发动准备（检查是否存在合法的对象，并进行取对象操作）
function c65357623.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc,race)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c65357623.filter(chkc) end
	-- 检查场上是否存在至少1只表侧表示的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c65357623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的不死族怪兽作为效果对象
	Duel.SelectTarget(tp,c65357623.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①的处理（让作为对象的怪兽直到回合结束时攻击力上升或下降1000）
function c65357623.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=1000
		-- 让发动效果的玩家选择“攻击力上升”或“攻击力下降”，若选择后者则将变动数值设为-1000
		if Duel.SelectOption(tp,aux.Stringid(65357623,1),aux.Stringid(65357623,2))==1 then atk=-1000 end  --"攻击力上升/攻击力下降"
		-- 直到回合结束时，那只怪兽的攻击力上升1000或者下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：除外的表侧表示且可以回到卡组的不死族怪兽
function c65357623.retfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 效果②的发动准备（检查自身是否可以盖放，以及除外区是否有符合条件的不死族怪兽）
function c65357623.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable()
		-- 检查除外区是否存在至少1只自己的不死族怪兽
		and Duel.IsExistingMatchingCard(c65357623.retfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁信息，表明此效果包含将墓地的这张卡移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理（将除外的1只不死族怪兽回到卡组，并将这张卡在场上盖放，设置离场除外约束）
function c65357623.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示信息“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外的1只自己的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c65357623.retfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- 给选中的卡片显示被选择的动画效果
		Duel.HintSelection(g)
		-- 若成功将选择的怪兽送回卡组，且这张卡仍存在于墓地，则将这张卡在自己场上盖放
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
