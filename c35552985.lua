--刻まれし魔の讃聖
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有恶魔族·光属性怪兽的场合才能发动。在自己场上把1只「刻魔衍生物」（恶魔族·光·1星·攻/守0）特殊召唤。这个回合，自己不用恶魔族怪兽不能攻击宣言。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「刻魔」怪兽被对方的效果破坏的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：自己场上的表侧表示怪兽不存在的场合或者只有恶魔族·光属性怪兽的场合才能发动。在自己场上把1只「刻魔衍生物」（恶魔族·光·1星·攻/守0）特殊召唤。这个回合，自己不用恶魔族怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「刻魔」怪兽被对方的效果破坏的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在非恶魔族·光属性的表侧表示怪兽
function s.cfilter(c)
	return not (c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsFaceup()
end
-- 效果①的发动条件，判断场上是否不存在表侧表示怪兽或仅存在恶魔族·光属性怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场上不存在非恶魔族·光属性的表侧表示怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时的处理函数，判断是否可以发动
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 判断是否可以特殊召唤token
		Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) end
	-- 设置操作信息为召唤token
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果①的发动处理函数，执行特殊召唤token并设置不能攻击宣言效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤token
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_LIGHT) then
		-- 创建token
		local token=Duel.CreateToken(tp,id+o)
		-- 将token特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置不能攻击宣言效果，仅对非恶魔族怪兽生效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能攻击宣言效果的目标过滤函数，仅对非恶魔族怪兽生效
function s.atktg(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 过滤函数，用于判断被破坏的怪兽是否为刻魔族且在场上正面表示且为盖放状态
function s.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(0x1b0)
end
-- 效果②的发动条件，判断是否为对方破坏且被破坏的怪兽为刻魔族且为盖放状态
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.cfilter2,1,e:GetHandler(),tp)
end
-- 效果②的发动时的处理函数，判断是否可以发动
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息为盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②的发动处理函数，执行盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否与效果相关，若相关则执行盖放
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
