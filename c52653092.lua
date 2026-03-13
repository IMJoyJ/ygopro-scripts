--SNo.0 ホープ・ゼアル
-- 效果：
-- 相同阶级的「No.」超量怪兽×3
-- 规则上，这张卡的阶级当作1阶使用。这张卡也能把手卡1张「升阶魔法」通常魔法卡丢弃，在自己场上的「希望皇 霍普」怪兽上面重叠来超量召唤。
-- ①：这张卡的超量召唤不会被无效化。
-- ②：在这张卡的超量召唤成功时，对方不能把效果发动。
-- ③：这张卡的攻击力·守备力上升这张卡的超量素材数量×1000。
-- ④：对方回合1次，把这张卡1个超量素材取除才能发动。这个回合对方不能把效果发动。
function c52653092.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c52653092.mfilter,c52653092.xyzcheck,3,3,c52653092.ovfilter,aux.Stringid(52653092,0),c52653092.xyzop)  --"是否在自己场上的「希望皇 霍普」怪兽上面重叠来超量召唤?"
	-- ①：这张卡的超量召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c52653092.effcon)
	c:RegisterEffect(e2)
	-- ②：在这张卡的超量召唤成功时，对方不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c52653092.effcon2)
	e3:SetOperation(c52653092.spsumsuc)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击力·守备力上升这张卡的超量素材数量×1000。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c52653092.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	-- ④：对方回合1次，把这张卡1个超量素材取除才能发动。这个回合对方不能把效果发动。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(52653092,1))
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(0,TIMING_DRAW_PHASE)
	e6:SetCountLimit(1)
	e6:SetCondition(c52653092.actcon)
	e6:SetCost(c52653092.actcost)
	e6:SetOperation(c52653092.actop)
	c:RegisterEffect(e6)
end
-- 设置该卡的超量阶级为0阶
aux.xyz_number[52653092]=0
-- 过滤满足条件的怪兽：表侧表示、超量怪兽、属于No.系列
function c52653092.mfilter(c,xyzc)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 检查叠放的怪兽数量是否为1个阶级
function c52653092.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 过滤满足条件的手牌：属于升阶魔法系列、魔法卡、可丢弃
function c52653092.cfilter(c)
	return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL and c:IsDiscardable()
end
-- 过滤满足条件的场上的怪兽：表侧表示、属于希望皇霍普系列
function c52653092.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 超量召唤时的处理函数：检查手牌是否存在升阶魔法并丢弃
function c52653092.xyzop(e,tp,chk)
	-- 判断是否可以发动超量召唤的条件：检查手牌中是否有升阶魔法
	if chk==0 then return Duel.IsExistingMatchingCard(c52653092.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌的操作：丢弃一张升阶魔法
	Duel.DiscardHand(tp,c52653092.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果发动条件：该卡为超量召唤
function c52653092.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动条件：该卡为超量召唤
function c52653092.effcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 超量召唤成功时设置连锁限制：禁止对方发动效果
function c52653092.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制：禁止对方发动效果直到回合结束
	Duel.SetChainLimitTillChainEnd(c52653092.chlimit)
end
-- 连锁限制函数：只允许自己发动效果
function c52653092.chlimit(e,ep,tp)
	return tp==ep
end
-- 攻击力计算函数：攻击力等于超量素材数量×1000
function c52653092.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 效果发动条件：当前回合不是自己回合
function c52653092.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否不是自己回合
	return Duel.GetTurnPlayer()~=tp
end
-- 效果发动的费用：取除1个超量素材
function c52653092.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时执行的操作：设置对方不能发动效果直到回合结束
function c52653092.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个禁止对方发动效果的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	-- 设置该效果为始终生效（不被无效）
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
