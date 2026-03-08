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
	-- ①：自己主要阶段，把满足发动条件的1张「源数」通常魔法卡从卡组送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
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
-- 过滤函数，用于筛选满足条件的「源数」通常魔法卡（必须是魔法卡、属于源数卡组、可以作为墓地代价、并且具有可发动效果）
function c41418852.cpfilter(c)
	return c:GetType()==TYPE_SPELL and c:IsSetCard(0x14a) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,false)~=nil
end
-- 设置发动时的标记，表示已进入发动阶段
function c41418852.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 选择并处理发动效果的魔法卡，将选中的卡送去墓地，并复制其发动效果
function c41418852.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查场上是否存在满足条件的「源数」通常魔法卡
		return Duel.IsExistingMatchingCard(c41418852.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c41418852.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选中的魔法卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前效果的连锁信息，防止被响应
	Duel.ClearOperationInfo(0)
end
-- 执行复制的魔法卡效果
function c41418852.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
-- 判断是否为源数超量怪兽因超量素材去除而发动的效果
function c41418852.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsSetCard(0x14a)
		and ep==e:GetOwnerPlayer() and re:GetActivateLocation()&LOCATION_MZONE~=0
end
-- 返回原效果的发动信息，用于替代超量素材去除
function c41418852.rop(e,tp,eg,ep,ev,re,r,rp)
	return ev
end
