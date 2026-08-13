--ギャラクシー・クィーンズ・ライト
-- 效果：
-- ①：以自己场上1只7星以上的怪兽为对象才能发动。自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
function c52340274.initial_effect(c)
	-- ①：以自己场上1只7星以上的怪兽为对象才能发动。自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52340274.target)
	e1:SetOperation(c52340274.activate)
	c:RegisterEffect(e1)
end
-- 判断一张怪兽卡是否为表侧表示且等级在7星以上，用于选择对象时的过滤条件。
function c52340274.filter1(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
-- 判断一张怪兽卡是否为表侧表示且当前等级大于0，用于筛选将被改变等级的怪兽。
function c52340274.filter2(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果发动时的目标选择与合法性判定：若chkc提供对象则验证其为自己场上表侧表示且7星以上的怪兽；初始检查时需存在1只可选对象，且自己场上存在至少2只表侧表示且等级大于0的怪兽。
function c52340274.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52340274.filter1(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示且7星以上的怪兽，作为可以发动的前提之一。
	if chk==0 then return Duel.IsExistingTarget(c52340274.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查自己场上是否存在至少2只表侧表示且当前等级大于0的怪兽，作为该效果发动的另一个前提条件。
		and Duel.IsExistingMatchingCard(c52340274.filter2,tp,LOCATION_MZONE,0,2,nil) end
	-- 向发动玩家发送“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动玩家从自己场上选择1只表侧表示且7星以上的怪兽，并将其登记为这个效果的对象。
	Duel.SelectTarget(tp,c52340274.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若对象仍与效果关联且为表侧表示，则获取自己场上除对象外所有表侧表示且等级大于0的怪兽，将它们的等级全部变为对象怪兽的当前等级，持续到回合结束。
function c52340274.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己场上除对象外所有表侧表示且当前等级大于0的怪兽，这些怪兽的等级将被统一变更。
		local g=Duel.GetMatchingGroup(c52340274.filter2,tp,LOCATION_MZONE,0,tc)
		local lc=g:GetFirst()
		local lv=tc:GetLevel()
		while lc do
			-- 自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			lc:RegisterEffect(e1)
			lc=g:GetNext()
		end
	end
end
