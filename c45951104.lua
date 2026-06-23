--ボット・ハーダー
-- 效果：
-- ①：以对方场上1只里侧守备表示怪兽或者原本持有者是自己的表侧表示怪兽为对象才能发动。作为对象的怪兽不存在的场合或者作为对象的怪兽的原本持有者是自己的场合（里侧表示卡翻开确认），以下效果各适用。
-- ●给与对方200伤害。
-- ●除作为对象的怪兽外的对方场上的全部怪兽的控制权得到。
local s,id,o=GetID()
-- 创建并注册效果，设置为发动时点、取对象、伤害与控制权改变效果
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断目标是否为里侧表示怪兽或原本持有者是自己的表侧表示怪兽
function s.filter(c,tp)
	return c:IsFacedown() or (c:IsFaceup() and c:GetOwner()==tp)
end
-- 效果处理函数，设置选择对象的条件并进行选择，若对象原本持有者是自己则设置伤害信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	if g:GetCount()>0 and g:GetFirst():GetOwner()==tp then
		-- 设置操作信息，表示将对对方造成200伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
	end
end
-- 控制权改变过滤函数，判断目标是否可以改变控制权
function s.ctfilter(c)
	return c:IsControlerCanBeChanged(true)
end
-- 效果发动处理函数，确认对象卡是否为里侧表示并处理伤害与控制权转移
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在场且为里侧表示，则翻开确认该卡
	if tc and tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
	if not tc:IsRelateToChain() or tc:GetOwner()==tp then
		-- 给与对方200伤害
		Duel.Damage(1-tp,200,REASON_EFFECT)
		-- 获取除对象外对方场上的所有可改变控制权的怪兽
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,tc)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 将符合条件的对方怪兽的控制权转移给发动者
			Duel.GetControl(g,tp)
		end
	end
end
