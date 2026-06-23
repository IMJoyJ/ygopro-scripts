--赤き竜 ケッツァーコアトル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把龙族同调怪兽尽可能特殊召唤。这个回合，自己不能把怪兽特殊召唤。
-- ②：这张卡的攻击力上升自己场上的其他的同调怪兽的原本攻击力的合计数值。
-- ③：对方把怪兽的效果发动时才能发动。自己场上1只其他的龙族同调怪兽回到额外卡组，那个发动无效。
local s,id,o=GetID()
-- 注册卡片的初始效果，包括同调召唤手续、①同调召唤成功时尽可能特殊召唤墓地中龙族同调怪兽的效果、②上升场上其他同调怪兽原本攻击力合计数值的永续效果、③对方发动怪兽效果时让场上其他龙族同调怪兽回到额外卡组使该发动无效的效果
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把龙族同调怪兽尽可能特殊召唤。这个回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己场上的其他的同调怪兽的原本攻击力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- ③：对方把怪兽的效果发动时才能发动。自己场上1只其他的龙族同调怪兽回到额外卡组，那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡同调召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果特殊召唤目标的过滤条件：墓地的龙族同调怪兽且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与目标检查（Target函数）：判断自己场上是否存在空格且墓地中是否存在满足条件的龙族同调怪兽，设置特殊召唤操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只满足过滤条件的龙族同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理（Operation函数）：从墓地尽可能多地选择并特殊召唤龙族同调怪兽，并对发动效果的玩家附加本回合不能特殊召唤怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取墓地中不受王家长眠之谷影响且满足过滤条件的龙族同调怪兽
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local g=nil
		if tg:GetCount()>ft then
			-- 给玩家提示：选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=tg:Select(tp,ft,ft,nil)
		else
			g=tg
		end
		if g and g:GetCount()>0 then
			-- 将选择的龙族同调怪兽特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不能把怪兽特殊召唤。②：这张卡的攻击力上升自己场上的其他的同调怪兽的原本攻击力的合计数值。③：对方把怪兽的效果发动时才能发动。自己场上1只其他的龙族同调怪兽回到额外卡组，那个发动无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册本回合不能特殊召唤怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- ②效果攻击力计算的过滤条件：场上表侧表示的其他同调怪兽
function s.vfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ②效果中攻击力上升数值的计算函数：计算自己场上其他的同调怪兽的原本攻击力合计数值
function s.val(e,c)
	-- 获取己方场上除自身外所有表侧表示的同调怪兽
	local g=Duel.GetMatchingGroup(s.vfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetBaseAttack)
end
-- ③效果的发动条件：对方把怪兽的效果发动时，且该发动能被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果、此卡未被战斗破坏，且该连锁的发动可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ③效果回到额外卡组怪兽的过滤条件：自己场上表侧表示的其他龙族同调怪兽，且可以返回额外卡组
function s.disfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- ③效果的发动准备与目标检查（Target函数）：判断自己场上是否存在其他满足返回额外卡组条件的龙族同调怪兽，并设定无效发动和返回额外卡组的操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除自身以外的满足过滤条件的龙族同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 设置操作信息为使连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息为将场上的怪兽返回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
end
-- ③效果的处理（Operation函数）：选择自己场上1只其他的龙族同调怪兽回到额外卡组，使对方怪兽效果的发动无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示：选择要返回额外卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己场上1只其他的龙族同调怪兽
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e))
	-- 为选择的怪兽显示选中动画
	Duel.HintSelection(g)
	-- 将选择的龙族同调怪兽送回额外卡组
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and g:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
		-- 使对方怪兽效果的发动无效
		Duel.NegateActivation(ev)
	end
end
