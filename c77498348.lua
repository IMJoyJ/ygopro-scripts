--カオス・ソルジャー －宵闇の使者－
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性和暗属性的怪兽数量相同的场合，把那之内的其中1个属性全部除外的场合才能特殊召唤。这张卡的属性也当作「光」使用。这张卡特殊召唤成功时，可以把为特殊召唤而除外的怪兽属性的以下效果发动。这个效果发动的回合，自己不能进行战斗阶段。
-- ●光：选择场上1只怪兽除外。
-- ●暗：对方手卡随机选1张直到对方的结束阶段时里侧表示除外。
function c77498348.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡的属性也当作「光」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	-- 自己墓地的光属性和暗属性的怪兽数量相同的场合，把那之内的其中1个属性全部除外的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77498348,0))  --"除外光属性"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c77498348.spcon)
	e3:SetOperation(c77498348.spop)
	e3:SetLabel(ATTRIBUTE_LIGHT)
	e3:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(77498348,1))  --"除外暗属性"
	e4:SetLabel(ATTRIBUTE_DARK)
	c:RegisterEffect(e4)
	-- 这张卡特殊召唤成功时，可以把为特殊召唤而除外的怪兽属性的以下效果发动。这个效果发动的回合，自己不能进行战斗阶段。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(77498348,2))  --"除外"
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(c77498348.rmcon)
	e5:SetCost(c77498348.rmcost)
	e5:SetTarget(c77498348.rmtg)
	e5:SetOperation(c77498348.rmop)
	c:RegisterEffect(e5)
	e3:SetLabelObject(e5)
	e4:SetLabelObject(e5)
end
-- 过滤自己墓地中可作为特殊召唤Cost除外的指定属性怪兽
function c77498348.spfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
-- 判定是否满足自身特殊召唤的条件
function c77498348.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中光属性怪兽的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	-- 判定自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定墓地中光属性怪兽数量大于0且与暗属性怪兽数量相同
		and ct>0 and ct==Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
		-- 判定墓地中是否存在足够数量的、可作为Cost除外的指定属性怪兽
		and Duel.IsExistingMatchingCard(c77498348.spfilter,tp,LOCATION_GRAVE,0,ct,nil,e:GetLabel())
end
-- 执行自身特殊召唤的除外Cost操作，并记录除外的怪兽属性
function c77498348.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取墓地中所有可作为Cost除外的指定属性怪兽
	local g=Duel.GetMatchingGroup(c77498348.spfilter,tp,LOCATION_GRAVE,0,nil,e:GetLabel())
	-- 将这些怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	e:GetLabelObject():SetLabel(e:GetLabel())
end
-- 判定是否由自身特殊召唤规则特殊召唤成功
function c77498348.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 发动效果的Cost处理，限制本回合不能进行战斗阶段
function c77498348.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定当前是否为主要阶段1（因为不能进行战斗阶段，所以只能在主要阶段1发动）
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 这个效果发动的回合，自己不能进行战斗阶段。●光：选择场上1只怪兽除外。●暗：对方手卡随机选1张直到对方的结束阶段时里侧表示除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册本回合不能进行战斗阶段的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动的目标选择与效果分类设置
function c77498348.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then
		if e:GetLabel()==ATTRIBUTE_LIGHT then
			-- （光属性效果）判定场上是否存在可以作为除外对象的怪兽
			return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		else
			-- （暗属性效果）判定对方手牌是否存在可以除外的卡片
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN)
		end
	end
	if e:GetLabel()==ATTRIBUTE_LIGHT then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择场上1只怪兽作为除外对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		-- 设置除外场上怪兽的效果处理信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		-- 设置除外对方手牌的效果处理信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
		e:SetProperty(0)
	end
end
-- 效果处理的具体操作
function c77498348.rmop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==ATTRIBUTE_LIGHT then
		-- 获取选择的除外对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将该怪兽表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 获取对方手牌中可以除外的卡片
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)
		if g:GetCount()==0 then return end
		local rg=g:RandomSelect(tp,1)
		local tc=rg:GetFirst()
		-- 将随机选出的对方手牌里侧表示除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
		tc:RegisterFlagEffect(77498348,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 直到对方的结束阶段时里侧表示除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCondition(c77498348.retcon)
		e1:SetOperation(c77498348.retop)
		-- 注册在回合结束时将卡片送回手牌的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定是否满足将除外卡片送回手牌的条件
function c77498348.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(77498348)==0 then
		e:Reset()
		return false
	else
		-- 判定当前是否为对方的回合
		return Duel.GetTurnPlayer()==1-tp
	end
end
-- 执行将除外卡片送回手牌的操作
function c77498348.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将除外的卡片送回对方手牌
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
