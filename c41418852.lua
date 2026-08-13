--ヌメロン・ネットワーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段，把满足发动条件的1张「源数」通常魔法卡从卡组送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
-- ②：只要这张卡在场地区域存在，自己场上的「源数」超量怪兽把超量素材取除来让效果发动的场合，也能不把超量素材取除来发动。
function c41418852.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段，把满足发动条件的1张「源数」通常魔法卡从卡组送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41418852,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,41418852)
	e1:SetCost(c41418852.cpcost)
	e1:SetTarget(c41418852.cptg)
	e1:SetOperation(c41418852.cpop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，自己场上的「源数」超量怪兽把超量素材取除来让效果发动的场合，也能不把超量素材取除来发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41418852,1))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c41418852.rcon)
	e2:SetOperation(c41418852.rop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的「源数」通常魔法卡：必须是通常魔法卡、属于「源数」字段、可作为COST送去墓地，且该卡具有满足发动条件的可发动效果（CheckActivateEffect返回非nil）。
function c41418852.cpfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x14a) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,false)~=nil
end
-- COST声明函数：检查支付阶段仅置标记Label为1并返回true（表示接受支付），实际选卡与送墓推迟到目标选择阶段处理。
function c41418852.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 目标选择与发动处理：先检查COST标记并确认卡组存在符合条件的「源数」通常魔法卡；发动时选择1张符合条件的卡，获取其发动效果信息，将其作为COST送去墓地；再将被复制效果的Property、Target和效果本体保存到当前效果中，以便后续按该魔法卡的效果处理；最后清除操作信息。
function c41418852.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在至少1张满足cpfilter条件的「源数」通常魔法卡。
		return Duel.IsExistingMatchingCard(c41418852.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 向操作玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选择1张符合条件的「源数」通常魔法卡。
	local g=Duel.SelectMatchingCard(tp,c41418852.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选择的「源数」通常魔法卡作为COST送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，使被复制的魔法卡效果不会被当作实际发动而被响应。
	Duel.ClearOperationInfo(0)
end
-- 效果处理函数：取出之前保存的被复制魔法卡效果，以当前效果为上下文调用它原本的Operation函数，从而完成“这个效果变成和那张魔法卡发动时的效果相同”的处理。
function c41418852.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
-- 满足代替取除超量素材的条件：我方「源数」超量怪兽在主要怪兽区发动需要取除超量素材的效果（且取除原因为COST）时，本卡可代替该取除过程。
function c41418852.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsSetCard(0x14a)
		and ep==e:GetOwnerPlayer() and re:GetActivateLocation()&LOCATION_MZONE~=0
end
-- 代替取除超量素材的操作：返回ev（非0即真）使替换成立，即视为已从“取除素材”替换为“不取除素材”。
function c41418852.rop(e,tp,eg,ep,ev,re,r,rp)
	return ev
end
