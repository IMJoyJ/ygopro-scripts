--セフィラ・メタトロン
-- 效果：
-- 从额外卡组特殊召唤的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区的从额外卡组特殊召唤的怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只怪兽加入手卡。
-- ②：以这张卡以外的自己以及对方场上的从额外卡组特殊召唤的怪兽各1只为对象才能发动。那2只怪兽直到结束阶段除外。
function c85216896.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只以上满足过滤条件（从额外卡组特殊召唤）的怪兽作为素材
	aux.AddLinkProcedure(c,c85216896.matfilter,2)
	-- ①：这张卡所连接区的从额外卡组特殊召唤的怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85216896,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,85216896)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c85216896.thcon)
	e2:SetTarget(c85216896.thtg)
	e2:SetOperation(c85216896.thop)
	c:RegisterEffect(e2)
	-- ②：以这张卡以外的自己以及对方场上的从额外卡组特殊召唤的怪兽各1只为对象才能发动。那2只怪兽直到结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85216896,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,85216897)
	e3:SetTarget(c85216896.rmtg)
	e3:SetOperation(c85216896.rmop)
	c:RegisterEffect(e3)
end
-- 过滤条件：必须是从额外卡组特殊召唤的怪兽
function c85216896.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤条件：原本由自己控制、在连接端被战斗或对方效果破坏的从额外卡组特殊召唤的怪兽
function c85216896.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	return c:IsPreviousControler(tp) and bit.extract(zone,seq)~=0 and c:IsSummonLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果①的发动条件：检查被破坏的卡片中是否存在满足条件的怪兽
function c85216896.thcon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone()
	return eg:IsExists(c85216896.cfilter,1,nil,tp,zone)
end
-- 过滤条件：自己墓地的怪兽，或者额外卡组表侧表示的灵摆怪兽
function c85216896.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查是否存在可加入手牌的卡，并设置回收手牌的操作信息
function c85216896.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或额外卡组是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85216896.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理的操作信息：将自己墓地或额外卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果①的效果处理：从墓地或额外卡组选择1只满足条件的怪兽加入手牌
function c85216896.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地（受王家之谷影响）或额外卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c85216896.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：场上表侧表示且从额外卡组特殊召唤的、可以被除外的怪兽
function c85216896.rmfilter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToRemove()
end
-- 效果②的发动准备：选择自己与对方场上各1只满足条件的怪兽作为对象，并设置除外的操作信息
function c85216896.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在除这张卡以外的、满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c85216896.rmfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c85216896.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只除这张卡以外的、满足条件的怪兽作为对象
	local g1=Duel.SelectTarget(tp,c85216896.rmfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足条件的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c85216896.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁处理的操作信息：将选中的2只怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
-- 效果②的效果处理：将选中的2只怪兽暂时除外，并注册在回合结束阶段将它们返回场上的延迟效果
function c85216896.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁上仍合法的、且可以被除外的对象怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsAbleToRemove,nil)
	if g:GetCount()~=2 then return end
	-- 将这些怪兽因效果暂时除外，并检查是否有怪兽成功被除外
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		-- 筛选出实际被成功除外的卡片组
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		local c=e:GetHandler()
		-- 遍历所有被成功除外的怪兽
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(85216896,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		og:KeepAlive()
		-- 那2只怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetCondition(c85216896.retcon)
		e1:SetOperation(c85216896.retop)
		-- 注册全局环境效果，用于在回合结束阶段将除外的怪兽返回场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：带有本卡效果标记的卡片，用于确认需要返回场上的怪兽
function c85216896.retfilter(c)
	return c:GetFlagEffect(85216896)~=0
end
-- 返回场上效果的发动条件：检查被除外的卡片组中是否存在带有标记的怪兽
function c85216896.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(c85216896.retfilter,1,nil)
end
-- 返回场上效果的处理：将所有带有标记的被除外怪兽返回场上
function c85216896.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():Filter(c85216896.retfilter,nil)
	-- 遍历所有需要返回场方的怪兽
	for tc in aux.Next(g) do
		-- 将怪兽返回到场上
		Duel.ReturnToField(tc)
	end
end
