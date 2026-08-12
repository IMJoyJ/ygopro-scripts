--熾天龍 ジャッジメント
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤的场合，同调素材怪兽必须全部是相同属性的怪兽。
-- ①：自己墓地有调整4种类以上存在，这张卡是已同调召唤的场合，1回合1次，把基本分支付一半才能发动。这张卡以外的场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
-- ②：自己结束阶段发动。从自己卡组上面把4张卡除外。
function c41659072.initial_effect(c)
	-- 添加同调召唤手续，要求同调素材必须包含调整和调整以外的怪兽，且同调素材必须全部是相同属性的怪兽
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.NonTuner(nil),1,99,c41659072.syncheck)
	c:EnableReviveLimit()
	-- 这张卡同调召唤的场合，同调素材怪兽必须全部是相同属性的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c41659072.sumlimit)
	c:RegisterEffect(e1)
	-- 自己墓地有调整4种类以上存在，这张卡是已同调召唤的场合，1回合1次，把基本分支付一半才能发动。这张卡以外的场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41659072,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c41659072.condition)
	e2:SetCost(c41659072.cost)
	e2:SetTarget(c41659072.target)
	e2:SetOperation(c41659072.operation)
	c:RegisterEffect(e2)
	-- 自己结束阶段发动。从自己卡组上面把4张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41659072,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c41659072.condition2)
	e3:SetTarget(c41659072.target2)
	e3:SetOperation(c41659072.operation2)
	c:RegisterEffect(e3)
end
-- 检查同调素材是否全部是相同属性的怪兽
function c41659072.syncheck(g)
	-- 检查同调素材是否全部是相同属性的怪兽
	return aux.SameValueCheck(g,Card.GetAttribute)
end
-- 限制该卡只能通过同调召唤特殊召唤，且不能被无效或复制
function c41659072.sumlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO or not se
end
-- 判断是否满足效果发动条件：该卡已通过同调召唤，且自己墓地存在4种类以上的调整怪兽
function c41659072.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地所有调整怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_TUNER)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and g:GetClassCount(Card.GetCode)>3
end
-- 支付一半基本分作为发动代价
function c41659072.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分作为发动代价
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置效果目标：场上的所有卡
function c41659072.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足效果发动条件：场上有至少一张卡在场上
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有卡的集合
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息：破坏场上所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行效果：破坏场上所有卡，并在回合结束时禁止非龙族怪兽特殊召唤
function c41659072.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有卡的集合（排除自身）
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏场上所有卡
	Duel.Destroy(sg,REASON_EFFECT)
	-- 创建并注册一个回合结束时生效的效果，禁止非龙族怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41659072.splimit)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 设定禁止非龙族怪兽特殊召唤的限制条件
function c41659072.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON)
end
-- 判断是否为当前回合玩家
function c41659072.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果目标：从卡组顶部除外4张卡
function c41659072.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取玩家卡组顶部的4张卡
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 设置连锁操作信息：除外卡组顶部4张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,4,0,0)
end
-- 执行效果：从卡组顶部除外4张卡
function c41659072.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组顶部的4张卡
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 禁止接下来的操作自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将卡组顶部的4张卡除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
