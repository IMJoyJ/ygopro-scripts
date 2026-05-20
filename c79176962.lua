--旋風機ストリボーグ
-- 效果：
-- 这张卡表侧表示上级召唤的场合解放的怪兽不送去墓地回到持有者手卡。
-- ①：1回合1次，丢弃1张手卡才能发动。和这张卡相同纵列的对方场上的卡全部回到持有者手卡。
function c79176962.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡才能发动。和这张卡相同纵列的对方场上的卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79176962,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c79176962.thcost)
	e1:SetTarget(c79176962.thtg)
	e1:SetOperation(c79176962.thop)
	c:RegisterEffect(e1)
	-- 这张卡表侧表示上级召唤的场合解放的怪兽不送去墓地回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c79176962.valcheck)
	c:RegisterEffect(e2)
	-- 这张卡表侧表示上级召唤的场合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SUMMON_COST)
	e3:SetOperation(c79176962.facechk)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价处理函数，用于检查并丢弃手牌。
function c79176962.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手牌中是否存在可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌作为发动的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选出可以回到手牌且在相同纵列的卡片。
function c79176962.thfilter(c,g)
	return c:IsAbleToHand() and g:IsContains(c)
end
-- 效果①的发动准备函数，检查目标并设置操作信息。
function c79176962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	-- 在发动阶段（chk==0）检查对方场上相同纵列是否存在可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c79176962.thfilter,tp,0,LOCATION_ONFIELD,1,nil,cg) end
	-- 获取对方场上相同纵列中所有可以回到手牌的卡片。
	local g=Duel.GetMatchingGroup(c79176962.thfilter,tp,0,LOCATION_ONFIELD,nil,cg)
	-- 设置将这些卡片送回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果①的实际处理函数，将相同纵列的对方卡片送回手牌。
function c79176962.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 在效果处理时，重新获取对方场上相同纵列中所有可以回到手牌的卡片。
		local g=Duel.GetMatchingGroup(c79176962.thfilter,tp,0,LOCATION_ONFIELD,nil,cg)
		if g:GetCount()>0 then
			-- 将符合条件的卡片全部送回持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 素材检查函数，用于在表侧表示上级召唤成功时，将解放的怪兽重定向至手牌。
function c79176962.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	if e:GetLabel()==1 then
		e:SetLabel(0)
		while tc do
			-- 解放的怪兽不送去墓地回到持有者手卡
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetValue(LOCATION_HAND)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
-- 召唤代价处理函数，用于标记当前为表侧表示上级召唤。
function c79176962.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end
