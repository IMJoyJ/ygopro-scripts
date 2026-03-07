--天威無崩の地
-- 效果：
-- ①：只要这张卡在场地区域存在，效果怪兽以外的场上的表侧表示怪兽不受怪兽的效果影响。
-- ②：1回合1次，对方把效果怪兽特殊召唤的场合，若自己场上有效果怪兽以外的怪兽存在则能发动。自己抽2张。
function c39730727.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，效果怪兽以外的场上的表侧表示怪兽不受怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c39730727.etarget)
	e2:SetValue(c39730727.efilter)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把效果怪兽特殊召唤的场合，若自己场上有效果怪兽以外的怪兽存在则能发动。自己抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_ACTIVATE_CONDITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c39730727.drcon)
	e3:SetTarget(c39730727.drtg)
	e3:SetOperation(c39730727.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标怪兽是否为效果怪兽以外的怪兽
function c39730727.etarget(e,c)
	return not c:IsType(TYPE_EFFECT)
end
-- 过滤函数，用于判断效果是否为怪兽效果
function c39730727.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数，用于判断自己场上的怪兽是否为效果怪兽以外的表侧表示怪兽或里侧表示怪兽
function c39730727.drfilter1(c)
	return (not c:IsType(TYPE_EFFECT) and c:IsFaceup()) or c:IsFacedown()
end
-- 过滤函数，用于判断对方特殊召唤成功的怪兽是否为效果怪兽且为对方召唤的表侧表示怪兽
function c39730727.drfilter2(c,tp)
	return c:IsType(TYPE_EFFECT) and c:IsSummonPlayer(1-tp) and c:IsFaceup()
end
-- 条件函数，用于判断是否满足发动效果的条件，即自己场上存在效果怪兽以外的怪兽且对方有效果怪兽被特殊召唤
function c39730727.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组，检查自己场上是否存在效果怪兽以外的怪兽
	return Duel.IsExistingMatchingCard(c39730727.drfilter1,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(c39730727.drfilter2,1,nil,tp)
end
-- 目标函数，用于设置效果的目标玩家和抽卡数量
function c39730727.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前正在处理的连锁的对象玩家为玩家tp
	Duel.SetTargetPlayer(tp)
	-- 设置当前正在处理的连锁的对象参数为2
	Duel.SetTargetParam(2)
	-- 设置当前处理的连锁的操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数，用于执行抽卡效果
function c39730727.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
