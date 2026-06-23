--七皇昇格
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组选以下的卡之内任意1张加入手卡或在卡组最上面放置。
-- ●「七皇升格」以外的「七皇」魔法·陷阱卡
-- ●「异晶人的」魔法·陷阱卡
-- ●「升阶魔法」速攻魔法卡
-- ②：从额外卡组特殊召唤的怪兽在对方场上存在的场合，把墓地的这张卡除外，从手卡把1张「升阶魔法」魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
function c23153227.initial_effect(c)
	-- ①：从卡组选以下的卡之内任意1张加入手卡或在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23153227,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23153227)
	e1:SetTarget(c23153227.target)
	e1:SetOperation(c23153227.operation)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的怪兽在对方场上存在的场合，把墓地的这张卡除外，从手卡把1张「升阶魔法」魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23153227,1))  --"复制升阶魔法"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,23153228)
	e2:SetCondition(c23153227.cpcon)
	e2:SetCost(c23153227.cpcost)
	e2:SetTarget(c23153227.cptg)
	e2:SetOperation(c23153227.cpop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的卡：「七皇」魔法·陷阱卡（不包括七皇升格）、「异晶人的」魔法·陷阱卡、以及「升阶魔法」速攻魔法卡。
function c23153227.filter(c)
	return (not c:IsCode(23153227) and c:IsSetCard(0x175) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0x176) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0x95) and c:IsType(TYPE_QUICKPLAY))
end
-- 效果的target函数，检查玩家是否在卡组中存在满足filter条件的卡。
function c23153227.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否在卡组中存在满足filter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c23153227.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果的operation函数，选择一张满足条件的卡，可以选择加入手牌或放置在卡组最上方。
function c23153227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张满足filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23153227.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择将卡放置在卡组最上方。
		if tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(23153227,2))==0 then  --"在卡组最上面放置"
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认该卡的展示。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 洗切玩家的卡组。
			Duel.ShuffleDeck(tp)
			-- 将选中的卡移动到卡组最上方。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认玩家卡组最上方的卡。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 过滤函数，用于筛选在额外怪兽区召唤的怪兽。
function c23153227.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果的condition函数，检查对方场上是否存在从额外卡组特殊召唤的怪兽。
function c23153227.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(c23153227.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果的cost函数，设置标签用于后续判断。
function c23153227.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，用于筛选手牌中可作为cost的「升阶魔法」魔法卡。
function c23153227.cpfilter(c)
	return c:GetType()&TYPE_SPELL==TYPE_SPELL and c:IsSetCard(0x95) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果的target函数，检查是否满足cost并选择要复制效果的「升阶魔法」魔法卡。
function c23153227.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否满足cost条件：墓地的这张卡可除外，且手牌中存在满足cpfilter条件的卡。
		return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c23153227.cpfilter,tp,LOCATION_HAND,0,1,nil)
	end
	e:SetLabel(0)
	-- 将墓地的这张卡除外作为cost。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择一张满足cpfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23153227.cpfilter,tp,LOCATION_HAND,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	-- 将选中的卡送去墓地作为cost。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁中的操作信息。
	Duel.ClearOperationInfo(0)
end
-- 效果的operation函数，执行复制的「升阶魔法」魔法卡的效果。
function c23153227.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
