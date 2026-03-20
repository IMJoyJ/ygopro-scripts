--光のピラミッド
-- 效果：
-- 自己场上表侧表示存在的这张卡从场上离开的场合，自己场上存在的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」破坏并从游戏中除外。
function c53569894.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的这张卡从场上离开的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c53569894.checkop)
	c:RegisterEffect(e2)
	-- 自己场上存在的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」破坏并从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject(e2)
	e3:SetOperation(c53569894.leave)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」
function c53569894.filter(c)
	return c:IsFaceup() and c:IsCode(15013468,51402177)
end
-- 检查卡片是否处于无效状态或未准备就绪
function c53569894.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当卡片离开场上的时候，如果满足条件则破坏并除外符合条件的怪兽
function c53569894.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp) then
		-- 检索满足条件的卡片组
		local g=Duel.GetMatchingGroup(c53569894.filter,tp,LOCATION_ONFIELD,0,nil)
		-- 以效果原因将目标卡片破坏并送入除外区
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
