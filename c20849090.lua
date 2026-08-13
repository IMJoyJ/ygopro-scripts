--Kozmo－フォアランナー
-- 效果：
-- ①：这张卡不会成为对方的效果的对象。
-- ②：自己准备阶段发动。自己回复1000基本分。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只6星以下的「星际仙踪」怪兽特殊召唤。
function c20849090.initial_effect(c)
	-- ①：这张卡不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果的判定值为aux.tgoval，即当效果发动者为这张卡控制者的对手时返回true，使这张卡不能成为对方效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。自己回复1000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c20849090.reccon)
	e2:SetTarget(c20849090.rectg)
	e2:SetOperation(c20849090.recop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只6星以下的「星际仙踪」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c20849090.spcon)
	e3:SetCost(c20849090.spcost)
	e3:SetTarget(c20849090.sptg)
	e3:SetOperation(c20849090.spop)
	c:RegisterEffect(e3)
end
-- ②效果的发动条件：仅当当前回合玩家是这张卡的控制者（即自己的准备阶段）时，效果才能发动。
function c20849090.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果控制者，若是则条件成立。
	return tp==Duel.GetTurnPlayer()
end
-- ②效果的发动时处理：无条件通过后，将回复对象设为自己，回复数值设为1000，并登记操作信息为回复1000基本分。
function c20849090.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的对象玩家设置为效果控制者（自己），表示回复LP的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设置为1000，即要回复的基本分数值。
	Duel.SetTargetParam(1000)
	-- 向系统登记操作信息：类别为LP回复，对象玩家为自己，回复数值为1000，供连锁判定和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- ②效果处理时的操作：从连锁信息中取出之前保存的回复对象玩家和回复数值，实际执行基本分回复。
function c20849090.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家和参数（回复数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让p玩家回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡因战斗破坏或效果破坏而被送去墓地。
function c20849090.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③效果的发动代价：将墓地的这张卡除外。先检查这张卡在墓地且可以除外作为代价；支付时将其表侧表示除外。
function c20849090.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将作为效果持有者的这张卡从墓地以表侧表示除外，作为发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 特殊召唤的筛选条件：卡组中的「星际仙踪」怪兽、等级6以下、并且可以被效果特殊召唤。
function c20849090.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标：确认自己场上有怪兽区空位，且卡组中存在至少1只满足特殊召唤条件的「星际仙踪」怪兽。
function c20849090.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动确认时检查自己场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中是否存在至少1只满足spfilter条件的「星际仙踪」怪兽。
		and Duel.IsExistingMatchingCard(c20849090.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：类别为特殊召唤，预计从卡组特殊召唤1只怪兽，用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理时的操作：从卡组选择1只符合条件的「星际仙踪」怪兽，以表侧表示特殊召唤到自己场上。
function c20849090.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否还有怪兽区空格，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给控制者显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选出1张满足特殊召唤条件的「星际仙踪」怪兽，由玩家选择。
	local g=Duel.SelectMatchingCard(tp,c20849090.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不额外检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
