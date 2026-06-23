--ジェムナイトレディ・ラピスラズリ
-- 效果：
-- 「宝石骑士·小琉」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。自己对「宝石骑士女郎·琉璃」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从卡组·额外卡组把1只「宝石骑士」怪兽送去墓地，给与对方为场上的特殊召唤的怪兽数量×500伤害。
function c47611119.initial_effect(c)
	c:SetSPSummonOnce(47611119)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为99645428的怪兽和1个满足过滤条件的「宝石骑士」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,99645428,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),1,false,false)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组·额外卡组把1只「宝石骑士」怪兽送去墓地，给与对方为场上的特殊召唤的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c47611119.splimit)
	c:RegisterEffect(e1)
	-- 从卡组·额外卡组检索1只「宝石骑士」怪兽送入墓地，并对对方造成伤害
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c47611119.damtg)
	e2:SetOperation(c47611119.damop)
	c:RegisterEffect(e2)
end
-- 限制该卡只能通过融合召唤从额外卡组特殊召唤
function c47611119.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 过滤满足条件的「宝石骑士」怪兽，且必须是怪兽类型并能被送去墓地
function c47611119.filter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 过滤满足条件的特殊召唤怪兽
function c47611119.ctfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 判断是否满足发动条件：场上有特殊召唤的怪兽且自己卡组或额外卡组有「宝石骑士」怪兽
function c47611119.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或额外卡组是否存在满足条件的「宝石骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47611119.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
		-- 检查自己场上是否存在至少1只特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 统计自己场上的特殊召唤怪兽数量
	local ct=Duel.GetMatchingGroupCount(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，准备对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
-- 发动效果时选择1只「宝石骑士」怪兽送去墓地，并计算场上特殊召唤的怪兽数量对对方造成相应伤害
function c47611119.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组或额外卡组选择1只满足条件的「宝石骑士」怪兽送入墓地
	local g=Duel.SelectMatchingCard(tp,c47611119.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 获取连锁效果的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 再次统计自己场上的特殊召唤怪兽数量
		local ct=Duel.GetMatchingGroupCount(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 对对方造成场上特殊召唤的怪兽数量×500的伤害
		Duel.Damage(p,ct*500,REASON_EFFECT)
	end
end
