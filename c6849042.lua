--超古代恐獣
-- 效果：
-- 这张卡可以把1只恐龙族怪兽解放表侧攻击表示上级召唤。
-- ①：这张卡在怪兽区域存在，从自己墓地有恐龙族怪兽特殊召唤时才能发动。自己从卡组抽1张。
function c6849042.initial_effect(c)
	-- 这张卡可以把1只恐龙族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6849042,0))  --"把1只恐龙族怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c6849042.otcon)
	e1:SetOperation(c6849042.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：这张卡在怪兽区域存在，从自己墓地有恐龙族怪兽特殊召唤时才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6849042,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c6849042.drcon)
	e2:SetTarget(c6849042.drtg)
	e2:SetOperation(c6849042.drop)
	c:RegisterEffect(e2)
end
-- 过滤场上可以作为解放素材的恐龙族怪兽（自己场上的，或对方场上表侧表示的）
function c6849042.otfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and (c:IsControler(tp) or c:IsFaceup())
end
-- 1只怪兽解放上级召唤的条件判断函数
function c6849042.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足解放过滤条件的怪兽组
	local mg=Duel.GetMatchingGroup(c6849042.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断自身等级是否在7星以上、最少解放数量是否不大于1，且场上是否存在1只满足条件的解放怪兽
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 1只怪兽解放上级召唤的具体操作函数
function c6849042.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足解放过滤条件的怪兽组
	local mg=Duel.GetMatchingGroup(c6849042.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只用于上级召唤解放的怪兽
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的怪兽作为上级召唤的素材解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤从自己墓地特殊召唤的恐龙族怪兽
function c6849042.cfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:IsPreviousControler(tp)
end
-- 抽卡效果的发动条件（不包含自身，且有恐龙族怪兽从自己墓地特殊召唤成功）
function c6849042.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c6849042.cfilter,1,nil,tp)
end
-- 抽卡效果的发动准备与目标确认函数
function c6849042.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理函数
function c6849042.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
