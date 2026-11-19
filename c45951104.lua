--ボット・ハーダー
-- 效果：
-- ①：以对方场上1只里侧守备表示怪兽或者原本持有者是自己的表侧表示怪兽为对象才能发动。作为对象的怪兽不存在的场合或者作为对象的怪兽的原本持有者是自己的场合（里侧表示卡翻开确认），以下效果各适用。
-- ●给与对方200伤害。
-- ●除作为对象的怪兽外的对方场上的全部怪兽的控制权得到。
local s,id,o=GetID()
-- 初始化卡片效果，注册发动时取对方场上怪兽为对象、根据条件给与对方200伤害并夺取对方场上其他怪兽控制权的通常魔法卡发动效果
function s.initial_effect(c)
	-- ①：以对方场上1只里侧守备表示怪兽或者原本持有者是自己的表侧表示怪兽为对象才能发动。作为对象的怪兽不存在的场合或者作为对象的怪兽的原本持有者是自己的场合（里侧表示卡翻开确认），以下效果各适用。●给与对方200伤害。●除作为对象的怪兽外的对方场上的全部怪兽的控制权得到。
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
-- 过滤可作为对象的对方场上怪兽：里侧表示怪兽，或者原本持有者为自己的表侧表示怪兽
function s.filter(c,tp)
	return c:IsFacedown() or (c:IsFaceup() and c:GetOwner()==tp)
end
-- 效果发动合法性检查与取对象处理：检查对方场上存在可作为对象的怪兽，让玩家选择其中1只作为对象；若选中的对象原本持有者为自己，则登记给与对方200伤害的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	-- 检查对方怪兽区是否存在至少1只满足条件的里侧表示或原本持有者为自己的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向发动玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家从对方怪兽区选择1只符合条件的怪兽作为本次连锁的对象
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	if g:GetCount()>0 and g:GetFirst():GetOwner()==tp then
		-- 登记本次连锁包含给与对方玩家200点效果伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
	end
end
-- 过滤可改变控制权的怪兽：检查怪兽控制权是否可以改变（忽略己方怪兽区格位限制）
function s.ctfilter(c)
	return c:IsControlerCanBeChanged(true)
end
-- 执行①效果处理：若对象怪兽仍在场上且为里侧表示则翻开给发动玩家确认；若对象怪兽已不再与连锁关联或其原本持有者为自己，则给与对方200伤害，并在那之后夺取对方场上除对象怪兽外全部可转移控制权怪兽的控制权
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对方场上对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍在场上且处于里侧表示，则翻开给发动玩家确认
	if tc and tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
	if not tc:IsRelateToChain() or tc:GetOwner()==tp then
		-- 以效果给与对方玩家200点伤害
		Duel.Damage(1-tp,200,REASON_EFFECT)
		-- 获取对方怪兽区中除对象怪兽以外所有控制权可以改变的怪兽卡片组
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,tc)
		if g:GetCount()>0 then
			-- 中断当前效果处理流程，使之后夺取控制权的处理与伤害处理分开进行
			Duel.BreakEffect()
			-- 让发动玩家得到对方场上除对象怪兽外的对应怪兽的控制权
			Duel.GetControl(g,tp)
		end
	end
end
