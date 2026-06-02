--ジェムナイト・クォーツ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合，把这张卡从手卡丢弃才能发动。从卡组把1张「融合」永续魔法卡在自己场上盖放。这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从自己墓地把「宝石骑士·石英」以外的1只「宝石骑士」怪兽加入手卡。
function c35622739.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合，把这张卡从手卡丢弃才能发动。从卡组把1张「融合」永续魔法卡在自己场上盖放。这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35622739)
	e1:SetCondition(c35622739.stcon)
	e1:SetCost(c35622739.stcost)
	e1:SetTarget(c35622739.sttg)
	e1:SetOperation(c35622739.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从自己墓地把「宝石骑士·石英」以外的1只「宝石骑士」怪兽加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,35622740)
	e2:SetCondition(c35622739.thcon)
	e2:SetTarget(c35622739.thtg)
	e2:SetOperation(c35622739.thop)
	c:RegisterEffect(e2)
end
-- 检查对方场上是否有怪兽存在，以判断是否满足效果①的发动条件
function c35622739.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 定义效果①的发动代价：把手卡的这张卡丢弃
function c35622739.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 作为发动代价，将这张卡丢弃并送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中可盖放的「融合」永续魔法卡
function c35622739.stfilter(c)
	return c:IsSetCard(0x46) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 定义效果①的靶向/可行性检查逻辑：确认卡组是否存在可盖放的目标卡
function c35622739.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在至少1张满足盖放条件的「融合」永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35622739.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义效果①的具体处理逻辑：从卡组选择1张「融合」永续魔法卡盖放，并限制本回合只能从额外卡组特殊召唤「宝石骑士」怪兽
function c35622739.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「融合」永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c35622739.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
	-- 这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。②：这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从自己墓地把「宝石骑士·石英」以外的1只「宝石骑士」怪兽加入手卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35622739.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册全局的特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤限制规则：不能从额外卡组特殊召唤「宝石骑士」以外的怪兽
function c35622739.splimit(e,c)
	return not c:IsSetCard(0x1047) and c:IsLocation(LOCATION_EXTRA)
end
-- 检查是否满足效果②的发动条件：作为融合素材送去墓地或被除外
function c35622739.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤墓地中除「宝石骑士·石英」以外的「宝石骑士」怪兽卡
function c35622739.thfilter(c)
	return not c:IsCode(35622739) and c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果②的对象确认和可行性检查逻辑，以及设置回收操作信息
function c35622739.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认墓地是否存在可回收的目标卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35622739.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向系统声明此效果的操作信息为“从墓地将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 定义效果②的具体处理逻辑：从墓地将1只「宝石骑士」怪兽加入手卡
function c35622739.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1只满足条件的「宝石骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35622739.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 在场上/墓地中闪烁显示选中的卡片以告知对方
		Duel.HintSelection(g)
		-- 将选中的怪兽卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
