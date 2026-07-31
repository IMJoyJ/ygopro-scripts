--「A」細胞培養装置
-- 效果：
-- 每次从场上A指示物被取除，给这张卡放置1个A指示物。这张卡被破坏时，这张卡放置的全部A指示物给场上表侧表示存在的怪兽放置。
function c64163367.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次从场上A指示物被取除，给这张卡放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_REMOVE_COUNTER+0x100e)
	e2:SetOperation(c64163367.ctop1)
	c:RegisterEffect(e2)
	-- 这张卡被破坏时，这张卡放置的全部A指示物给场上表侧表示存在的怪兽放置。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c64163367.regop)
	c:RegisterEffect(e0)
	-- 这张卡被破坏时，这张卡放置的全部A指示物给场上表侧表示存在的怪兽放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64163367,0))  --"放置「A指示物」"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c64163367.ctcon2)
	e3:SetOperation(c64163367.ctop2)
	e3:SetLabelObject(e0)
	c:RegisterEffect(e3)
end
c64163367.counter_add_list={0x100e}
c64163367.mentioned_counter={
	[0x100e]=true,
}
-- 放置指示物处理：给这张卡放置1个A指示物
function c64163367.ctop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x100e,1)
end
-- 离场前准备：获取这张卡离场前的A指示物数量并记录在标签中
function c64163367.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x100e)
	e:SetLabel(ct)
end
-- 发动条件检查：传递记录的指示物数量并确认数量大于0
function c64163367.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end
-- 放置指示物处理：依次选择场上表侧表示的怪兽，将原记录数量的A指示物逐个放置
function c64163367.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 获取双方场上所有表侧表示存在的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	for i=1,ct do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
