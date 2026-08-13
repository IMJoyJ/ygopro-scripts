--BK スパー
-- 效果：
-- 自己场上有名字带有「燃烧拳击手」的怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的场合，这个回合自己不能进行战斗阶段。
function c32750341.initial_effect(c)
	-- 自己场上有名字带有「燃烧拳击手」的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c32750341.spcon)
	e1:SetOperation(c32750341.spop)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：判断卡片是否表侧表示且属于「燃烧拳击手」系列（0x1084）。
function c32750341.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084)
end
-- 特殊召唤规则的条件函数：若召唤对象为nil则视为满足；否则检查自己主要怪兽区有空格且自己场上有表侧表示的「燃烧拳击手」怪兽。
function c32750341.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上主要怪兽区是否存在可用空格，确保特殊召唤有位置。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1张表侧表示且卡名含有「燃烧拳击手」字段的怪兽。
		Duel.IsExistingMatchingCard(c32750341.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤成功后的处理操作：为本回合自己附加不能进行战斗阶段的誓约效果。
function c32750341.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤过的场合，这个回合自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该不能进入战斗阶段的誓约效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
