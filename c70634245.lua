--真魔六武衆－エニシ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，把自己墓地的「六武众」怪兽任意数量除外，以那个数量的对方场上的怪兽为对象才能发动。那些怪兽回到手卡。
-- ②：自己场上的战士族怪兽的攻击力·守备力只在战斗阶段内上升500。
-- ③：这张卡被送去墓地的场合才能发动。自己的除外状态的1只「六武众」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、同调召唤成功时除外墓地「六武众」使对方场上怪兽回手、战斗阶段战士族攻防上升、送去墓地时特殊召唤除外状态的「六武众」等效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，把自己墓地的「六武众」怪兽任意数量除外，以那个数量的对方场上的怪兽为对象才能发动。那些怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"让对方场上的怪兽回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的战士族怪兽的攻击力·守备力只在战斗阶段内上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上的战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetCondition(s.adcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。自己的除外状态的1只「六武众」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：这张卡同调召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：自己墓地可以作为cost除外的「六武众」怪兽
function s.costfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果①的cost处理：标记Label以在target中检测是否能支付除外墓地怪兽的cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 效果①的目标选择函数，处理除外墓地怪兽作为cost，并选择相同数量的对方场上怪兽作为效果对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()==100 then
			-- 检查自己墓地是否存在至少1只可除外的「六武众」怪兽，且对方场上是否存在至少1只可回手的怪兽
			return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil)
		else return false end
	end
	-- 获取对方场上可以成为效果对象且能回到手卡的怪兽的最大数量
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1到rt张满足条件的「六武众」怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 将选择的墓地怪兽表侧表示除外作为发动cost，并获取实际除外的数量
	local cg=Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择与除外数量相同数量的对方场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,cg,cg,nil)
	-- 设置连锁信息，包含回手牌的操作分类和对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 过滤条件：仍与当前效果有关联且是怪兽的卡
function s.thfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsType(TYPE_MONSTER)
end
-- 效果①的操作函数：将作为对象的对方场上的怪兽回到持有者手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(s.thfilter,nil,e)
	if #rg>0 then
		-- 因效果将符合条件的怪兽送回持有者手卡
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
-- 效果②和③的生效条件：当前处于战斗阶段（从战斗阶段开始到战斗阶段结束）
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤条件：自己除外状态的表侧表示「六武众」怪兽，且可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的目标选择函数：检查自己场上是否有空怪兽位，以及除外状态是否存在可特殊召唤的「六武众」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己除外状态是否存在至少1只满足特殊召唤条件的「六武众」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁信息，包含从除外状态特殊召唤1只怪兽的操作分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果③的操作函数：将除外状态的1只「六武众」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用的怪兽区域，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外状态的卡中选择1只满足条件的「六武众」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
