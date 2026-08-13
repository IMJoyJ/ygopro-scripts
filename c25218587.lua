--ライトロード・アイギス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己场上的「光道」怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ②：这张卡从卡组送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 定义卡片的初始效果：为这张卡注册①的发动效果（无效对方表侧表示卡）和②的诱发效果（从卡组送去墓地时自身盖放），并分别设置1回合1次的次数限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以最多有自己场上的「光道」怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡从卡组送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"在场上盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 筛选自己场上表侧表示且属于「光道」系列的怪兽，用于计算①效果可选对象的数量上限。
function s.filter(c)
	return c:IsSetCard(0x38) and c:IsFaceup()
end
-- ①效果的目标处理：计算自己场上表侧表示「光道」怪兽数量作为可选对象上限，检查对方场上有可无效的表侧表示卡，选择1~上限张对方表侧表示卡为对象，并登记无效效果的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上表侧表示「光道」怪兽的数量，作为可选择对方卡的数量上限。
	local ct=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):FilterCount(s.filter,nil)
	-- 若当前是连锁处理中的对象合法性检查，则判断该卡是否为对方场上可被无效的表侧表示卡。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 发动条件检查：对方场上有可无效的表侧表示卡且自己场上有「光道」怪兽（ct>0）时才可发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) and ct>0 end
	-- 向玩家显示“请选择要无效的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上选择1~ct张可无效的表侧表示卡作为对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 登记本次连锁处理的无效效果操作信息，处理对象为已选择的卡，数量为选择张数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果处理：对对象卡逐一进行无效化，包括使相关连锁无效、赋予效果无效和效果无效化状态，若为陷阱怪兽还使其陷阱怪兽效果无效，持续到回合结束。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中所有仍与此效果关联的卡（通常是发动时选择的对象）。
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历这些对象卡，逐一处理。
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与该对象卡相关的连锁效果无效，并设定为变里侧时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- ②效果的发动条件：这张卡从卡组送去墓地（之前所在位置为卡组）时才能发动。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- ②效果的目标判定：检查这张卡可以被盖放，并登记其从墓地离开并盖放到场上的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 登记操作信息：将这张卡从墓地离开（盖放）作为处理对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关，则将其盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上里侧表示盖放。
		Duel.SSet(tp,c)
	end
end
