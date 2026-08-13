--七皇昇格
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组选以下的卡之内任意1张加入手卡或在卡组最上面放置。
-- ●「七皇升格」以外的「七皇」魔法·陷阱卡
-- ●「异晶人的」魔法·陷阱卡
-- ●「升阶魔法」速攻魔法卡
-- ②：从额外卡组特殊召唤的怪兽在对方场上存在的场合，把墓地的这张卡除外，从手卡把1张「升阶魔法」魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
function c23153227.initial_effect(c)
	-- ①：从卡组选以下的卡之内任意1张加入手卡或在卡组最上面放置。●「七皇升格」以外的「七皇」魔法·陷阱卡●「异晶人的」魔法·陷阱卡●「升阶魔法」速攻魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23153227,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,23153227)
	e1:SetTarget(c23153227.target)
	e1:SetOperation(c23153227.operation)
	c:RegisterEffect(e1)
	-- ②：从额外卡组特殊召唤的怪兽在对方场上存在的场合，把墓地的这张卡除外，从手卡把1张「升阶魔法」魔法卡送去墓地才能发动。那张魔法卡发动时的效果适用。
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
-- 定义①效果的可选卡条件：非本卡名的「七皇」魔法·陷阱卡、或「异晶人的」魔法·陷阱卡、或「升阶魔法」速攻魔法卡。
function c23153227.filter(c)
	return (not c:IsCode(23153227) and c:IsSetCard(0x175) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0x176) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0x95) and c:IsType(TYPE_QUICKPLAY))
end
-- 效果①的发动条件：自己卡组中存在至少1张符合条件的卡片，否则无法发动。
function c23153227.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查自己卡组是否存在至少1张满足 c23153227.filter 条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c23153227.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理①效果：从自己卡组选择1张符合条件的卡，然后根据玩家选择将其加入手卡或放置在卡组最上方，并亮出确认。
function c23153227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要操作的卡”的提示消息，用于卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组中选择1张满足 c23153227.filter 条件的卡。
	local g=Duel.SelectMatchingCard(tp,c23153227.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 若选中的卡能被加入手牌且玩家选择了“加入手卡”选项，则执行加入手卡处理；否则执行放置在卡组最上方的处理。
		if tc:IsAbleToHand() and Duel.SelectOption(tp,1190,aux.Stringid(23153227,2))==0 then  --"在卡组最上面放置"
			-- 将选中的卡片加入持有者手卡（处理原因为效果）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的这张牌，以进行确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 洗切己方卡组，为将卡片放置在卡组顶做准备。
			Duel.ShuffleDeck(tp)
			-- 将选中的卡片移动到卡组最上方，即放置在卡组顶部。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认己方卡组最上方1张卡片，向双方展示放置结果。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 定义怪兽筛选条件：该怪兽是从额外卡组特殊召唤出来的。
function c23153227.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：对方场上存在至少1只从额外卡组特殊召唤的怪兽。
function c23153227.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽（以tp方视角的对方怪兽区域）。
	return Duel.IsExistingMatchingCard(c23153227.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 代价函数：在发动时设置标记（label=100）以允许后续目标处理执行真正的代价支付；仅检查发动条件时返回 true。
function c23153227.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 筛选手卡中可作为代价的「升阶魔法」魔法卡：必须是魔法卡、属于「升阶魔法」字段、可以送去墓地作为代价，且拥有可发动的效果（CheckActivateEffect 非 nil）。
function c23153227.cpfilter(c)
	return c:GetType()&TYPE_SPELL==TYPE_SPELL and c:IsSetCard(0x95) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,false)~=nil
end
-- 效果②的目标处理与代价支付：将墓地的这张卡除外，从手卡选择1张「升阶魔法」魔法卡送去墓地，并读取该魔法卡发动时的效果目标设定，为后续复制其效果作准备。
function c23153227.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 在效果发动前检查：墓地的这张卡能否作为代价除外，以及手卡中是否存在符合 cpfilter 条件的「升阶魔法」魔法卡。
		return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c23153227.cpfilter,tp,LOCATION_HAND,0,1,nil)
	end
	e:SetLabel(0)
	-- 将墓地的这张卡以表侧表示除外，作为②效果的发动代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 给玩家显示“请选择要送去墓地的卡”的提示消息，用于选择要送墓的升阶魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡中选择1张满足 cpfilter 条件的「升阶魔法」魔法卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c23153227.cpfilter,tp,LOCATION_HAND,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	-- 将选中的「升阶魔法」魔法卡从手卡送去墓地，作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，用于复制使用升阶魔法效果时避免该效果被响应。
	Duel.ClearOperationInfo(0)
end
-- 实际执行被复制效果：取出之前保存的升阶魔法效果，调用其操作函数以适用那张魔法卡发动时的效果。
function c23153227.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
