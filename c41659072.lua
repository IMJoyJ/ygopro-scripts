--熾天龍 ジャッジメント
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤的场合，同调素材怪兽必须全部是相同属性的怪兽。
-- ①：自己墓地有调整4种类以上存在，这张卡是已同调召唤的场合，1回合1次，把基本分支付一半才能发动。这张卡以外的场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
-- ②：自己结束阶段发动。从自己卡组上面把4张卡除外。
function c41659072.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（1只调整＋1~99只调整以外怪兽），并指定syncheck作为同调素材合法性检查函数。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.NonTuner(nil),1,99,c41659072.syncheck)
	c:EnableReviveLimit()
	-- 这张卡同调召唤的场合，同调素材怪兽必须全部是相同属性的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c41659072.sumlimit)
	c:RegisterEffect(e1)
	-- ①：自己墓地有调整4种类以上存在，这张卡是已同调召唤的场合，1回合1次，把基本分支付一半才能发动。这张卡以外的场上的卡全部破坏。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
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
	-- ②：自己结束阶段发动。从自己卡组上面把4张卡除外。
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
-- 定义同调素材检查函数syncheck，用于验证参与同调召唤的素材怪兽是否满足全部相同属性的限制。
function c41659072.syncheck(g)
	-- 检查同调素材组g中的所有怪兽的属性是否全部相同（通过SameValueCheck对所有素材的属性位掩码求交集判断）。
	return aux.SameValueCheck(g,Card.GetAttribute)
end
-- 定义特殊召唤条件判定函数：仅当召唤类型为同调召唤且存在召唤来源效果时，才允许这张卡进行特殊召唤。
function c41659072.sumlimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO or not se
end
-- 定义①效果的发动条件：这张卡已通过同调召唤成功，且自己墓地存在4种类以上（卡名不同）的调整怪兽。
function c41659072.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中的所有调整怪兽，以组（Group）形式保存。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_TUNER)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and g:GetClassCount(Card.GetCode)>3
end
-- 定义①效果的发动代价：以支付当前基本分一半的LP作为发动代价。
function c41659072.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前基本分一半的LP（向下取整）。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义①效果的发动目标：确认场上存在这张卡以外的卡，并准备将场上所有其他卡全部破坏。
function c41659072.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查：这张卡以外的场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 取得这张卡以外双方场上的全部卡（怪兽和魔陷）作为破坏对象集合。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 将本次破坏操作的信息（对象集合、数量）写入连锁，供其他卡牌效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义①效果的处理：破坏这张卡以外的场上所有卡，并给控制者附加直到回合结束不能特殊召唤龙族以外怪兽的自肃效果。
function c41659072.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得这张卡以外双方场上的全部卡（若这张卡仍在场上且与效果关联则排除自身）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将取得的全部卡以效果方式破坏。
	Duel.Destroy(sg,REASON_EFFECT)
	-- 这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。②：自己结束阶段发动。从自己卡组上面把4张卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41659072.splimit)
	-- 将自肃效果注册到当前玩家，使其在回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制函数：欲特殊召唤的怪兽不是龙族时禁止特殊召唤。
function c41659072.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON)
end
-- 定义②效果的发动条件：仅在自己的结束阶段且当前回合玩家是自己时发动。
function c41659072.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（tp），保证只在己方结束阶段触发。
	return tp==Duel.GetTurnPlayer()
end
-- 定义②效果的发动目标：无选择对象，设置除外自己卡组最上方4张卡的操作信息。
function c41659072.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得自己卡组最上方的4张卡作为将被除外的对象组。
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 将除外操作信息写入连锁：目标为己方卡组最上方4张卡，数量为4，分类为除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,4,0,0)
end
-- 定义②效果的处理：将自己卡组最上方4张卡除外。
function c41659072.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新取得自己卡组最上方的4张卡。
	local rg=Duel.GetDecktopGroup(tp,4)
	-- 禁用本次操作后的卡组洗切检查（从卡组顶端除外卡不需要洗切）。
	Duel.DisableShuffleCheck()
	-- 将取出的4张卡以表侧表示除外，原因记为效果。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
