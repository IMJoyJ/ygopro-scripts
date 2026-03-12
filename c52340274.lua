--ギャラクシー・クィーンズ・ライト
-- 效果：
-- ①：以自己场上1只7星以上的怪兽为对象才能发动。自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
function c52340274.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只7星以上的怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52340274.target)
	e1:SetOperation(c52340274.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出自己场上的表侧表示且等级大于等于7的怪兽
function c52340274.filter1(c)
	return c:IsFaceup() and c:IsLevelAbove(7)
end
-- 效果作用：过滤出自己场上的表侧表示且等级大于0的怪兽
function c52340274.filter2(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果作用：设置效果的处理目标为满足条件的怪兽
function c52340274.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52340274.filter1(chkc) end
	-- 效果作用：检查自己场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c52340274.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 效果作用：检查自己场上是否存在至少2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c52340274.filter2,tp,LOCATION_MZONE,0,2,nil) end
	-- 效果作用：向玩家提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 效果作用：选择满足条件的目标怪兽
	Duel.SelectTarget(tp,c52340274.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果原文内容：自己场上的全部怪兽的等级直到回合结束时变成和作为对象的怪兽相同等级。
function c52340274.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果作用：检索自己场上所有满足条件的怪兽组成组
		local g=Duel.GetMatchingGroup(c52340274.filter2,tp,LOCATION_MZONE,0,tc)
		local lc=g:GetFirst()
		local lv=tc:GetLevel()
		while lc do
			-- 效果作用：将目标怪兽的等级修改为指定等级，并在回合结束时重置
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
