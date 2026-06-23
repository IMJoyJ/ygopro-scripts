--E・HERO セイラーマン
-- 效果：
-- 「元素英雄 水泡侠」＋「元素英雄 羽翼侠」
-- 这只怪兽不用融合召唤不能特殊召唤。自己的魔法与陷阱卡区域有卡盖放的场合，这张卡可以直接攻击对方玩家。
function c14225239.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为79979666和21844576的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,79979666,21844576,true,true)
	-- 这只怪兽不用融合召唤不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的值为融合召唤限制函数，确保只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 自己的魔法与陷阱卡区域有卡盖放的场合，这张卡可以直接攻击对方玩家
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c14225239.dacon)
	c:RegisterEffect(e2)
end
c14225239.material_setcode=0x8
-- 定义过滤函数，用于检测场上是否有里侧表示的魔法与陷阱卡
function c14225239.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 定义条件函数，用于判断是否满足直接攻击的条件
function c14225239.dacon(e)
	-- 检查以当前玩家来看，魔法与陷阱区域是否存在至少1张里侧表示的卡
	return Duel.IsExistingMatchingCard(c14225239.filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
