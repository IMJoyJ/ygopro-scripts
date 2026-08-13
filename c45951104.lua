--ボット・ハーダー
-- 效果：
-- ①：以对方场上1只里侧守备表示怪兽或者原本持有者是自己的表侧表示怪兽为对象才能发动。作为对象的怪兽不存在的场合或者作为对象的怪兽的原本持有者是自己的场合（里侧表示卡翻开确认），以下效果各适用。
-- ●给与对方200伤害。
-- ●除作为对象的怪兽外的对方场上的全部怪兽的控制权得到。
local s,id,o=GetID()
-- 创建并注册“僵尸牧人”的①效果：该效果为魔法卡发动效果，取对象，涉及伤害与改变控制权。
function s.initial_effect(c)
	-- ①：以对方场上1只里侧守备表示怪兽或者原本持有者是自己的表侧表示怪兽为对象才能发动。
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
-- 定义选择对象的过滤条件：里侧表示怪兽，或表侧表示且原本持有者为发动玩家的怪兽。
function s.filter(c,tp)
	return c:IsFacedown() or (c:IsFaceup() and c:GetOwner()==tp)
end
-- 效果发动时的目标选择与操作信息预设定：检查是否存在合法对象，选择1只对象，若对象原持有者为己方则预先设置200伤害信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 发动时检查对方场上是否存在1只符合条件的对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 给玩家显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从对方场上选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	if g:GetCount()>0 and g:GetFirst():GetOwner()==tp then
		-- 当所选对象的原本持有者是己方时，设置操作信息：给对方造成200点伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
	end
end
-- 定义控制权变更的过滤条件：该怪兽可以被变更控制权（忽视转移后己方场上是否有空格）。
function s.ctfilter(c)
	return c:IsControlerCanBeChanged(true)
end
-- 效果处理整体：确认对象（里侧翻开），判断是否满足“对象不存在或其原本持有者为己方”的条件，依次适用伤害与取得控制权。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍存在于场上且为里侧表示，则将对象卡翻开给发动玩家确认。
	if tc and tc:IsOnField() and tc:IsFacedown() then Duel.ConfirmCards(tp,tc) end
	if not tc:IsRelateToChain() or tc:GetOwner()==tp then
		-- 给与对方玩家200点效果伤害。
		Duel.Damage(1-tp,200,REASON_EFFECT)
		-- 取得对方场上除对象怪兽以外、所有可以变更控制权的怪兽（不检查对方场上空格数）。
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,tc)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使随后的控制权取得作为另一段处理进行，避免错过时点。
			Duel.BreakEffect()
			-- 获得所选择的对方怪兽的控制权。
			Duel.GetControl(g,tp)
		end
	end
end
