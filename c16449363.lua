--スクラップ・シンクロン
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：以「同调士」调整为素材的同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
-- ②：自己场上的以下怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 初始化卡片效果，注册所有效果和条件
function s.initial_effect(c)
	-- 记录该卡具有「废品战士」的卡名记述
	aux.AddCodeList(c,60800381)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(20932152)
	c:RegisterEffect(e0)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- 以「同调士」调整为素材的同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_PRE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.hsyncon)
	e2:SetOperation(s.hsynreg)
	c:RegisterEffect(e2)
	-- 自己场上的以下怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的同调怪兽作为同调素材
function s.matval(e,c)
	-- 满足同调怪兽类型且为「同调士」调整的素材
	return c:IsType(TYPE_SYNCHRO) and aux.IsMaterialListSetCard(c,0x1017)
end
-- 判断是否为同调召唤且手卡中的废铁同调士可作为同调素材
function s.hsyncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_SYNCHRO and s.matval(nil,c:GetReasonCard()) and c:IsPreviousLocation(LOCATION_HAND)
end
-- 使用①效果的使用次数限制
function s.hsynreg(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():UseCountLimit(tp)
end
-- 筛选符合条件的被破坏怪兽
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsOriginalSetCard(0x66) and c:IsType(TYPE_SYNCHRO)
		-- 原本卡名包含「战士」的同调怪兽
		or aux.IsCodeListed(c,60800381) and c:IsType(TYPE_MONSTER))
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏条件
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,c,tp)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 返回代替破坏的条件判断结果
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将该卡从游戏中除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
