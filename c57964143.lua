--白の仲裁
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
-- ②：对方怪兽的攻击宣言时，从手卡丢弃1只鱼族怪兽才能发动。对方场上的怪兽全部变成守备表示。
-- ③：自己的鱼族怪兽被战斗破坏的场合或者被送去墓地的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己墓地把1只鱼族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（当作调整）、②效果（对方攻击宣言时变守备）、③效果（鱼族被破坏/送墓时送墓此卡特召墓地鱼族）的注册。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：以自己场上1只鱼族怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作调整使用"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，从手卡丢弃1只鱼族怪兽才能发动。对方场上的怪兽全部变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.dfcon)
	e2:SetCost(s.dfcost)
	e2:SetTarget(s.dftg)
	e2:SetOperation(s.dfop)
	c:RegisterEffect(e2)
	-- ③：自己的鱼族怪兽被战斗破坏的场合或者被送去墓地的场合，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。从自己墓地把1只鱼族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon1)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.spcon2)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的非调整鱼族怪兽。
function s.filter(c)
	return c:IsRace(RACE_FISH) and c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ①效果的对象选择与发动准备函数，检查并选择自己场上1只表侧表示的非调整鱼族怪兽作为对象。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只满足过滤条件的怪兽并将其设为效果的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的处理函数，使选中的对象怪兽在回合结束前当作调整怪兽使用。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件函数，判断当前是否为对方的回合。
function s.dfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己（即对方回合）。
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤条件：手卡中可以作为Cost丢弃的鱼族怪兽。
function s.dfilter(c)
	return c:IsRace(RACE_FISH) and c:IsDiscardable(REASON_COST+REASON_DISCARD)
end
-- ②效果的Cost处理函数，检查并从手卡丢弃1只鱼族怪兽。
function s.dfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以丢弃的鱼族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1只鱼族怪兽作为发动Cost丢弃到墓地。
	Duel.DiscardHand(tp,s.dfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤条件：对方场上表侧攻击表示且可以改变表示形式的怪兽。
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- ②效果的靶向/目标检查函数，检查对方场上是否存在可改变表示形式的攻击表示怪兽，并设置改变表示形式的操作信息。
function s.dftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧攻击表示且可以改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧攻击表示且可以改变表示形式的怪兽。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁的操作信息，表示该效果包含改变这些怪兽表示形式的处理。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的处理函数，将对方场上所有表侧攻击表示的怪兽变成表侧守备表示。
function s.dfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧攻击表示且可以改变表示形式的怪兽。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		-- 将获取到的怪兽全部改变为表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：原本由自己控制、在场上是鱼族且因战斗被破坏的怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:GetPreviousRaceOnField()&RACE_FISH~=0 and c:IsReason(REASON_BATTLE)
end
-- 过滤条件：原本由自己控制、非因战斗被送去墓地的鱼族怪兽。
function s.cfilter2(c,tp)
	return not c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and s.check(c)
end
-- 辅助检查函数，判断卡片在离场前是否为鱼族（若在场上）或本身是否为鱼族（若不在场上）。
function s.check(c)
	if c:IsPreviousLocation(LOCATION_MZONE) then
		return c:GetPreviousRaceOnField()&RACE_FISH~=0 and c:IsRace(RACE_FISH)
	else
		return c:IsRace(RACE_FISH) and not c:IsPreviousLocation(LOCATION_ONFIELD)
	end
end
-- ③效果（战斗破坏）的发动条件函数，检查是否有自己的鱼族怪兽被战斗破坏。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ③效果（送去墓地）的发动条件函数，检查是否有自己的鱼族怪兽被送去墓地。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- ③效果的Cost处理函数，检查并将魔法与陷阱区域表侧表示的这张卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	-- 将这张卡作为发动Cost送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤条件：自己墓地中可以特殊召唤的鱼族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的靶向/目标检查函数，检查自己墓地是否存在可特召的鱼族怪兽且自己场上有空位，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少1只可以特殊召唤的鱼族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用于特殊召唤的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁的操作信息，表示该效果包含从自己墓地特殊召唤1张卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的处理函数，从自己墓地选择1只鱼族怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的鱼族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
