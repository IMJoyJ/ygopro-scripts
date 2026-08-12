--プロパ・ガンダケ
-- 效果：
-- ①：1回合1次，宣言自己场上的怪兽1个原本种族（兽族·昆虫族·植物族·岩石族）才能发动。这张卡变成宣言的种族。
-- ②：只要这张卡的①的效果适用的这张卡在怪兽区域存在，以下效果适用。
-- ●场上的表侧表示怪兽变成和这张卡相同种族。
-- ●和这张卡相同种族的场上的怪兽不会成为相同种族的对方场上的怪兽的效果的对象。
function c61681816.initial_effect(c)
	-- ①：1回合1次，宣言自己场上的怪兽1个原本种族（兽族·昆虫族·植物族·岩石族）才能发动。这张卡变成宣言的种族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61681816,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c61681816.rctg)
	e1:SetOperation(c61681816.rcop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡的①的效果适用的这张卡在怪兽区域存在，以下效果适用。●场上的表侧表示怪兽变成和这张卡相同种族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetCondition(c61681816.econ)
	e2:SetValue(c61681816.value)
	c:RegisterEffect(e2)
	-- ②：只要这张卡的①的效果适用的这张卡在怪兽区域存在，以下效果适用。●和这张卡相同种族的场上的怪兽不会成为相同种族的对方场上的怪兽的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c61681816.econ)
	e3:SetTarget(c61681816.etg)
	e3:SetValue(c61681816.tgoval)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示且原本种族为兽族、岩石族、植物族或昆虫族的怪兽
function c61681816.cfilter(c)
	local race=c:GetOriginalRace()
	return c:IsFaceup() and (race==RACE_BEAST or race==RACE_ROCK or race==RACE_PLANT or race==RACE_INSECT)
end
-- ①号效果的发动准备，获取可宣言的种族并让玩家进行宣言
function c61681816.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在原本种族为兽族、岩石族、植物族或昆虫族的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61681816.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有原本种族为兽族、岩石族、植物族或昆虫族的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c61681816.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	local race=0
	while tc do
		race=race|tc:GetOriginalRace()
		tc=g:GetNext()
	end
	-- 提示玩家选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从场上符合条件的怪兽的原本种族中宣言1个种族
	local rc=Duel.AnnounceRace(tp,1,race)
	e:SetLabel(rc)
end
-- ①号效果的解决，使这张卡变成宣言的种族，并给这张卡添加效果适用标记
function c61681816.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡变成宣言的种族。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(61681816,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 检查这张卡是否已适用①号效果（是否存在对应的Flag标记）
function c61681816.econ(e)
	return e:GetHandler():GetFlagEffect(61681816)>0
end
-- 返回这张卡当前的种族，用于将其他怪兽的种族改变为与这张卡相同
function c61681816.value(e,c)
	return e:GetHandler():GetRace()
end
-- 过滤场上和这张卡相同种族的怪兽，作为不能成为效果对象的目标
function c61681816.etg(e,c)
	return c:IsRace(e:GetHandler():GetRace())
end
-- 判定效果来源是否为对方场上的相同种族怪兽在怪兽区域发动的效果
function c61681816.tgoval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
		and re:GetActivateLocation()==LOCATION_MZONE and re:GetHandler():IsRace(e:GetHandler():GetRace())
end
