--セフェルの魔導書
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有魔法师族怪兽存在的场合，把这张卡以外的手卡1张「魔导书」卡给对方观看，以「创造之魔导书」以外的自己墓地1张「魔导书」通常魔法卡为对象才能发动。这张卡的效果变成和那张通常魔法卡发动时的效果相同。
function c56981417.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有魔法师族怪兽存在的场合，把这张卡以外的手卡1张「魔导书」卡给对方观看，以「创造之魔导书」以外的自己墓地1张「魔导书」通常魔法卡为对象才能发动。这张卡的效果变成和那张通常魔法卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56981417+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56981417.condition)
	e1:SetCost(c56981417.cost)
	e1:SetTarget(c56981417.target)
	e1:SetOperation(c56981417.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的魔法师族怪兽
function c56981417.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件：自己场上有魔法师族怪兽存在
function c56981417.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c56981417.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡中未公开的「魔导书」卡
function c56981417.cffilter(c)
	return c:IsSetCard(0x106e) and not c:IsPublic()
end
-- 发动代价：把这张卡以外的手卡1张「魔导书」卡给对方观看
function c56981417.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的「魔导书」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56981417.cffilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置提示信息为选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1张「魔导书」卡
	local g=Duel.SelectMatchingCard(tp,c56981417.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的卡给对方确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 过滤条件：自己墓地「创造之魔导书」以外的「魔导书」通常魔法卡，且该卡的发动效果有效
function c56981417.filter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(56981417) and c:GetType()==TYPE_SPELL and c:CheckActivateEffect(true,true,false)~=nil
end
-- 发动准备：选择墓地的「魔导书」通常魔法卡为对象，并复制其发动效果的属性与目标
function c56981417.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查墓地是否存在满足条件的「魔导书」通常魔法卡
	if chk==0 then return Duel.IsExistingTarget(c56981417.filter,tp,LOCATION_GRAVE,0,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e:SetCategory(0)
	-- 设置提示信息为选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地1张满足条件的「魔导书」通常魔法卡作为对象
	local g=Duel.SelectTarget(tp,c56981417.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	-- 清除当前效果的对象
	Duel.ClearTargetCard()
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 效果处理：执行被复制的通常魔法卡的效果
function c56981417.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te:GetHandler():IsRelateToEffect(e) then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end
