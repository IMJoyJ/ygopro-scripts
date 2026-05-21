--ドリラゴ
-- 效果：
-- 对方场上只有表侧表示的攻击力1600以上的怪兽存在的场合，这张卡可以对对方玩家进行直接攻击。
function c99050989.initial_effect(c)
	-- 对方场上只有表侧表示的攻击力1600以上的怪兽存在的场合，这张卡可以对对方玩家进行直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c99050989.dircon)
	c:RegisterEffect(e1)
end
-- 过滤出攻击力小于1600或里侧表示的怪兽
function c99050989.filter(c)
	return c:GetAttack()<1600 or c:IsFacedown()
end
-- 判断直接攻击的条件是否满足：对方魔陷区无卡，且怪兽区不存在攻击力小于1600或里侧表示的怪兽
function c99050989.dircon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方魔法与陷阱区域的卡片数量是否为0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)==0
		-- 检查对方怪兽区域是否不存在攻击力小于1600或里侧表示的怪兽
		and not Duel.IsExistingMatchingCard(c99050989.filter,tp,0,LOCATION_MZONE,1,nil)
end
