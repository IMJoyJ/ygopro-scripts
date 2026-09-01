--No.101 S・H・Ark Knight－ソウル・アサイラム
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡1个超量素材取除，可以从以下效果选择1个发动。●从自己墓地选1只4星怪兽。和那只怪兽是相同种族·属性而卡名不同的1只4星怪兽从卡组加入手卡。●以对方场上1只怪兽为对象才能发动。那只怪兽重叠在这张卡下面作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetTarget(s.dreptg)
	e2:SetOperation(s.drepop)
	c:RegisterEffect(e2)
end
-- 记录No.编号为101
aux.xyz_number[id]=101
-- ①效果的代价：取除1个超量素材
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 获取取除的超量素材卡
	local ct=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(ct)
	ct:CreateEffectRelation(e)
end
-- 过滤墓地中存在卡组对应检索目标的4星怪兽
function s.filter1(c,tp)
	-- 墓地存在4星怪兽且卡组有同种族·同属性不同名4星怪兽
	return c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c) and c:IsLevel(4)
end
-- 过滤卡组中同种族·同属性不同名的4星怪兽
function s.thfilter(c,tc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute()) and not c:IsCode(tc:GetCode()) and c:IsLevel(4)
end
-- 过滤可以作为超量素材重叠的怪兽
function s.filter2(c)
	return c:IsCanOverlay()
end
-- ①效果的目标：选择发动分支1或分支2
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then
			return false
		else
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter2(chkc)
		end
	end
	local ct=e:GetLabelObject()
	-- 检查是否满足分支1（检索同种族·同属性4星怪兽）
	local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,ct,tp)
	-- 检查是否满足分支2（取对方怪兽为超量素材）
	local b2=Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 玩家选择发动的效果分支
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		-- 设置加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择对方场上1只怪兽作为对象
		Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	end
end
-- ①效果的处理：执行选中的效果分支
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local ct=e:GetLabelObject()
		if not ct:IsRelateToChain() then ct=nil end
		-- 提示选择要参考的墓地怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从墓地选择1只4星怪兽
		local tg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,ct,tp)
		if tg:GetCount()>0 then
			-- 显示选中的墓地怪兽
			Duel.HintSelection(tg)
			-- 提示选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择同种族·同属性不同名的4星怪兽
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tg:GetFirst())
			if g:GetCount()>0 then
				-- 将选择的怪兽加入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 对方确认加入手牌的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif op==2 then
		-- 获取目标怪兽
		local tc=Duel.GetFirstTarget()
		local c=e:GetHandler()
		if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将目标怪兽原有的超量素材送去墓地
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将目标怪兽叠放作为超量素材
			Duel.Overlay(c,Group.FromCards(tc))
		end
	end
end
-- ②效果的代破目标：检查破坏原因并询问是否代替
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 玩家选择是否取除超量素材代替破坏
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- ②效果的代破处理：取除1个超量素材
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动效果提示
	Duel.Hint(HINT_CARD,0,id)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
