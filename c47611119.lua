--ジェムナイトレディ・ラピスラズリ
-- 效果：
-- 「宝石骑士·小琉」＋「宝石骑士」怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。自己对「宝石骑士女郎·琉璃」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从卡组·额外卡组把1只「宝石骑士」怪兽送去墓地，给与对方为场上的特殊召唤的怪兽数量×500伤害。
function c47611119.initial_effect(c)
	c:SetSPSummonOnce(47611119)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以卡名「宝石骑士·小琉」(99645428)和1只「宝石骑士」系列怪兽作为融合素材进行融合召唤，实现其融合素材要求。
	aux.AddFusionProcCodeFun(c,99645428,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1047),1,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c47611119.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组·额外卡组把1只「宝石骑士」怪兽送去墓地，给与对方为场上的特殊召唤的怪兽数量×500伤害。
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
-- 特殊召唤条件判定：如果这张卡不在额外卡组（例如已在场上或墓地）则不限制特殊召唤方式；若在额外卡组，则必须是融合召唤才能特殊召唤，从而限制其只能通过正规融合召唤出场。
function c47611119.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- 定义送墓筛选条件：选择卡组·额外卡组中的「宝石骑士」系列怪兽且能送去墓地的卡。
function c47611119.filter(c)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义特殊召唤怪兽筛选条件：选择持有“特殊召唤”召唤类型的怪兽，用于计算伤害时统计场上特殊召唤的怪兽数量。
function c47611119.ctfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 起动效果的发动条件与目标设定：发动时需存在可送去墓地的「宝石骑士」怪兽，且双方场上存在至少1只特殊召唤的怪兽；满足后设置伤害对象为对方并登记伤害信息。
function c47611119.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·额外卡组是否存在至少1只满足条件的「宝石骑士」怪兽可送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c47611119.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
		-- 检查双方场上是否存在至少1只被特殊召唤的怪兽，以保证可以计算伤害。
		and Duel.IsExistingMatchingCard(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 统计双方场上当前的特殊召唤怪兽数量，作为伤害倍率。
	local ct=Duel.GetMatchingGroupCount(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将当前效果的对象玩家设置为对方(1-tp)，指定伤害的承受者为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 登记连锁操作信息：此次效果包含伤害效果，伤害对象为对方玩家，伤害值为特殊召唤怪兽数量×500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
-- 效果处理：从卡组·额外卡组选择1只「宝石骑士」怪兽送去墓地，然后根据选中后双方场上特殊召唤的怪兽数量，给予对方玩家该数量×500的伤害。
function c47611119.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要送去墓地的卡”的提示，引导选择送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组·额外卡组选择1张满足条件的「宝石骑士」怪兽以送去墓地。
	local g=Duel.SelectMatchingCard(tp,c47611119.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「宝石骑士」怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 从当前连锁信息中读取之前设置的对象玩家，即承受伤害的对方玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 效果处理时再次统计双方场上特殊召唤的怪兽数量，作为最终伤害计算依据。
		local ct=Duel.GetMatchingGroupCount(c47611119.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 给予对方玩家ct×500点效果伤害，ct为场上特殊召唤的怪兽数量。
		Duel.Damage(p,ct*500,REASON_EFFECT)
	end
end
