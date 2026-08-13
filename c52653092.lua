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
-- 在辅助库中将这张卡的“No.”编号登记为0，用于“No.”字段相关效果判定，对应卡名中的“No.0”。
aux.xyz_number[52653092]=0
-- 超量素材候选过滤：必须是表侧表示的XYZ怪兽，且字段包含“No.”。
function c52653092.mfilter(c,xyzc)
	return c:IsFaceup() and c:IsXyzType(TYPE_XYZ) and c:IsSetCard(0x48)
end
-- 检查选择的素材组的阶级是否全部相同，满足“相同阶级的「No.」超量怪兽×3”的召唤条件。
function c52653092.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 手牌丢弃代价的过滤：满足字段“升阶魔法”、类型为通常魔法且可以丢弃的卡。
function c52653092.cfilter(c)
	return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL and c:IsDiscardable()
end
-- 特殊叠放召唤对象的过滤：自己场上的表侧表示且字段包含“希望皇”的怪兽，可在此类怪兽上重叠超量召唤。
function c52653092.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 追加的叠放召唤操作：当选择手卡丢弃“升阶魔法”的方式时，确认手牌有可丢弃的“升阶魔法”通常魔法卡，然后丢弃1张作为超量召唤手续的一部分。
function c52653092.xyzop(e,tp,chk)
	-- 代价确认：检查手牌中是否存在至少1张满足条件的“升阶魔法”通常魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52653092.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手卡丢弃1张满足条件的“升阶魔法”通常魔法卡（代价兼丢弃）。
	Duel.DiscardHand(tp,c52653092.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 条件：这张卡以超量召唤的方式成功出场（用于①效果的超量召唤不被无效化）。
function c52653092.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 条件：这张卡是超量召唤成功（用于②效果的触发）。
function c52653092.effcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 超量召唤成功时执行的操作：为当前连锁设置限制，使对方不能发动效果。
function c52653092.spsumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置直到连锁结束的连锁限制，只允许满足 chlimit 条件的玩家发动效果。
	Duel.SetChainLimitTillChainEnd(c52653092.chlimit)
end
-- 连锁限制判定：只有这张卡的控制者（tp）才能发动效果，对方不能发动效果。
function c52653092.chlimit(e,ep,tp)
	return tp==ep
end
-- 攻击力·守备力的提升值：这张卡的超量素材数量×1000。
function c52653092.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- ④的发动条件：当前回合玩家不是这张卡的控制者，即只能在对方回合发动。
function c52653092.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家与这张卡的控制者不同，满足“对方回合”的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ④的代价：取除这张卡的1个超量素材；先检查是否有素材可取，再实际取除。
function c52653092.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ④的效果处理：生成一个持续到结束阶段的永续效果，使对方不能发动任何效果。
function c52653092.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	-- 将该禁止效果的值设为恒真，即所有效果发动都被禁止。
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将这个不能发动效果的效果注册到场上，以这张卡控制者的视角对其对方生效。
	Duel.RegisterEffect(e1,tp)
end
