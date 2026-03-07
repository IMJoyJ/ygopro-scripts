--BK スパー
-- 效果：
-- 自己场上有名字带有「燃烧拳击手」的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的场合，这个回合自己不能进行战斗阶段。
function c32750341.initial_effect(c)
	-- 创建一个特殊召唤规则效果，允许自己场上有名字带有「燃烧拳击手」的怪兽时可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32750341.spcon)
	e1:SetOperation(c32750341.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测场上是否有表侧表示的「燃烧拳击手」怪兽
function c32750341.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function c32750341.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查玩家场上是否存在至少1只名字带有「燃烧拳击手」的表侧表示怪兽
		Duel.IsExistingMatchingCard(c32750341.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤时的处理函数，用于设置不能进行战斗阶段的效果
function c32750341.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置一个影响自己玩家的不能进入战斗阶段的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给对应玩家，使其在结束阶段重置
	Duel.RegisterEffect(e1,tp)
end
