--インフェルニティ・アーチャー
-- 效果：
-- 自己手卡是0张的场合，这张卡可以直接攻击对方玩家。
function c18724123.initial_effect(c)
	-- 自己手卡是0张的场合，这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c18724123.con)
	c:RegisterEffect(e1)
end
-- 检查当前控制者手卡数量是否为0
function c18724123.con(e)
	-- 获取当前卡片控制者手上卡片数量并判断是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end
