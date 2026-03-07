--ジェムナイト・クォーツ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合，把这张卡从手卡丢弃才能发动。从卡组把1张「融合」永续魔法卡在自己场上盖放。这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从自己墓地把「宝石骑士·石英」以外的1只「宝石骑士」怪兽加入手卡。
function c35622739.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合，把这张卡从手卡丢弃才能发动。从卡组把1张「融合」永续魔法卡在自己场上盖放。这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
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
	-- ②：这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。从自己墓地把「宝石骑士·石英」以外的1只「宝石骑士」怪兽加入手卡。
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
-- 效果作用：检查对方场上是否存在怪兽
function c35622739.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断对方场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果作用：支付丢弃手牌的代价
function c35622739.stcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 规则层面：将自身从手牌丢入墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义检索目标卡片的过滤条件
function c35622739.stfilter(c)
	return c:IsSetCard(0x46) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSSetable()
end
-- 效果作用：设置盖放魔法卡的检索条件
function c35622739.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c35622739.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果作用：执行盖放魔法卡并设置不能特殊召唤的效果
function c35622739.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 规则层面：选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c35622739.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡片盖放
		Duel.SSet(tp,g)
	end
	-- ①：对方场上有怪兽存在的场合，把这张卡从手卡丢弃才能发动。从卡组把1张「融合」永续魔法卡在自己场上盖放。这个回合，自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35622739.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面：注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：定义不能特殊召唤的过滤条件
function c35622739.splimit(e,c)
	return not c:IsSetCard(0x1047) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果作用：判断是否满足发动条件
function c35622739.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) and r==REASON_FUSION
end
-- 效果作用：定义检索目标卡片的过滤条件
function c35622739.thfilter(c)
	return not c:IsCode(35622739) and c:IsSetCard(0x1047) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：设置检索卡片的条件
function c35622739.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查墓地中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c35622739.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果作用：执行将卡片加入手牌的操作
function c35622739.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面：选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35622739.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面：显示选卡动画
		Duel.HintSelection(g)
		-- 规则层面：将卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
