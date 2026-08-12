--ドラグニティ－ブランディストック
-- 效果：
-- ①：把这张卡当作装备卡使用来装备的怪兽在同1次的战斗阶段中可以作2次攻击。
function c54455664.initial_effect(c)
	-- ①：把这张卡当作装备卡使用来装备的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
