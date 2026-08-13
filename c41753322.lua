--竜脚獣ブラキオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。这张卡可以把1只恐龙族怪兽解放表侧表示上级召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。
-- ③：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
function c41753322.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只恐龙族怪兽解放表侧表示上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41753322,0))  --"把1只恐龙族怪兽解放上级召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c41753322.otcon)
	e2:SetOperation(c41753322.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41753322,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c41753322.postg)
	e3:SetOperation(c41753322.posop)
	c:RegisterEffect(e3)
	-- ②：这张卡反转召唤成功的场合发动。这张卡以外的场上的怪兽全部变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41753322,1))  --"变成里侧守备"
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e4:SetTarget(c41753322.postg2)
	e4:SetOperation(c41753322.posop2)
	c:RegisterEffect(e4)
	-- ③：这张卡被攻击的场合，那次战斗发生的对对方的战斗伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e5:SetCondition(c41753322.dcon)
	-- 设置该效果的具体数值：这张卡被攻击的战斗中，对对方玩家造成的战斗伤害变为2倍。
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
-- 定义可作为解放祭品的恐龙族怪兽过滤条件：对象必须是恐龙族，且满足“由自己控制”或“表侧表示”，即自己场上的恐龙或对方场上的表侧恐龙。
function c41753322.otfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断上级召唤规则效果是否满足：若召唤的卡c为nil则返回true；否则需满足这张卡等级不低于7、所需解放数量不超过1、且场上存在1只符合条件的恐龙族怪兽可作为祭品。
function c41753322.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 取得场上可能作为祭品的恐龙族怪兽候选集合，范围是己方与对方的怪兽区。
	local mg=Duel.GetMatchingGroup(c41753322.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判定上级召唤条件成立：这张卡等级≥7、需求解放数≤1、且存在1只恐龙族祭品。
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 执行上级召唤的解放手续：先取得恐龙族祭品候选集合，让玩家选择1只恐龙族怪兽作为祭品，将其设为召唤素材并解放。
function c41753322.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 取得场上可能作为祭品的恐龙族怪兽候选集合，范围是己方与对方的怪兽区。
	local mg=Duel.GetMatchingGroup(c41753322.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 从候选集合中让玩家选择1只恐龙族怪兽作为上级召唤的解放祭品。
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选择的祭品怪兽解放，原因是召唤与用作召唤素材。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- ①效果的发动判定：若chk==0，则检查这张卡是否能变为里侧守备表示且本回合尚未发动过此效果；随后记录“本回合已使用过该效果”的标志，并设置将这张卡变更表示形式的操作信息。
function c41753322.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(41753322)==0 end
	c:RegisterFlagEffect(41753322,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：本效果将变更表示形式的卡为这张卡，数量为1张，类别为位置变更。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且为表侧表示，则将其变成里侧守备表示。
function c41753322.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变更为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动判定：必发效果，chk==0时直接返回true；发动时收集场上除自身外所有能变为里侧守备表示的怪兽，并设置操作信息。
function c41753322.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得场上除这张卡以外所有满足“可以被变为里侧守备表示”的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息：将上述收集到的所有怪兽变更表示形式，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果处理：取得场上除这张卡以外所有能变为里侧守备表示的怪兽，并将它们全部变成里侧守备表示。
function c41753322.posop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得场上除这张卡以外所有可以变为里侧守备表示的怪兽，用aux.ExceptThisCard(e)排除自身。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将选中的所有怪兽的表示形式变更为里侧守备表示。
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
-- ③效果的发动条件判断：这张卡被攻击时条件成立，即当前攻击对象是这张卡。
function c41753322.dcon(e)
	local c=e:GetHandler()
	-- 判定当前战斗阶段中，这张卡是否为攻击对象。
	return Duel.GetAttackTarget()==c
end
