--E・HERO セイラーマン
-- 效果：
-- 「元素英雄 水泡侠」＋「元素英雄 羽翼侠」
-- 这只怪兽不用融合召唤不能特殊召唤。自己的魔法与陷阱卡区域有卡盖放的场合，这张卡可以直接攻击对方玩家。
function c14225239.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为卡号79979666（元素英雄 水泡侠）与卡号21844576（元素英雄 羽翼侠）的2只怪兽，且支持其中1只使用替代素材（sub=true, insf=true）。
	aux.AddFusionProcCode2(c,79979666,21844576,true,true)
	-- 这只怪兽不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为aux.fuslimit，即只有通过融合召唤方式进行的特殊召唤才被允许。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 自己的魔法与陷阱卡区域有卡盖放的场合，这张卡可以直接攻击对方玩家。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c14225239.dacon)
	c:RegisterEffect(e2)
end
c14225239.material_setcode=0x8
-- 定义过滤器：满足条件的卡必须是里侧表示，且不在场地魔法格（sequence为5的场地区域）。
function c14225239.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 定义直接攻击的发动条件：自己魔法与陷阱卡区域存在至少1张里侧盖放的卡（不包括场地魔法区域的卡）。
function c14225239.dacon(e)
	-- 检查自己魔法与陷阱卡区域（含场地魔法格以外的区域）是否存在至少1张符合filter条件的里侧盖放卡。
	return Duel.IsExistingMatchingCard(c14225239.filter,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
