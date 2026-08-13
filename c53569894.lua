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
	-- 自己场上存在的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」破坏并从游戏中除外
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetLabelObject(e2)
	e3:SetOperation(c53569894.leave)
	c:RegisterEffect(e3)
end
-- 筛选出自己场上表侧表示且卡名为「斯芬克斯·安德鲁」或「斯芬克斯·迪蕾雅」的卡
function c53569894.filter(c)
	return c:IsFaceup() and c:IsCode(15013468,51402177)
end
-- 因离场前需要判断效果是否有效：若这张卡处于无效状态或尚未生效则标记为1，否则标记为0，供离场处理判断触发条件是否成立
function c53569894.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场时触发：若离场前效果有效且原控制者是自己，则选出自己场上符合条件的「斯芬克斯·安德鲁」和「斯芬克斯·迪蕾雅」并执行破坏、除外处理
function c53569894.leave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==0 and c:IsPreviousControler(tp) then
		-- 取得自己场上所有表侧表示且卡名为「斯芬克斯·安德鲁」或「斯芬克斯·迪蕾雅」的卡
		local g=Duel.GetMatchingGroup(c53569894.filter,tp,LOCATION_ONFIELD,0,nil)
		-- 将选出的怪兽破坏并除外，即送去除外区
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
