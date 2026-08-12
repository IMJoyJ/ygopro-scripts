--シンクロ・オーバートップ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的7·8星的龙族同调怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的等级变成1星，效果无效化。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己的同调怪兽被战斗破坏时，把墓地的这张卡除外才能发动。从额外卡组把1只「红龙」特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①和效果②的注册
function s.initial_effect(c)
	-- 将「红龙」（卡号63436931）加入此卡的效果关联卡片列表中
	aux.AddCodeList(c,63436931)
	-- ①：以自己墓地的7·8星的龙族同调怪兽任意数量为对象才能发动。那些怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的等级变成1星，效果无效化。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的同调怪兽被战斗破坏时，把墓地的这张卡除外才能发动。从额外卡组把1只「红龙」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置效果②的发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己墓地可以守备表示特殊召唤的7·8星龙族同调怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(7,8) and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备（Target阶段），检查并选择墓地的目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 获取玩家场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择任意数量（不超过可用怪兽区域空格数）的墓地目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置连锁处理中的操作信息，表示将特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- 效果①的实际处理（Operation阶段），处理特殊召唤、等级变更、效果无效以及额外卡组特殊召唤限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那些怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的等级变成1星，效果无效化。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“这个回合，自己不是同调怪兽不能从额外卡组特殊召唤”的限制效果
	Duel.RegisterEffect(e0,tp)
	-- 再次获取当前可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取在当前连锁中仍合法的目标怪兽
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #g>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #g>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽以表侧守备表示逐步特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的等级变成1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 限制函数：不能从额外卡组特殊召唤同调怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：检查被战斗破坏的怪兽是否是自己场上表侧表示的同调怪兽
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
end
-- 效果②的发动条件：自己的同调怪兽被战斗破坏时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数：额外卡组中可以特殊召唤的「红龙」
function s.spfilter2(c,e,tp)
	return c:IsCode(63436931) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否有可用的怪兽区域来特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动准备（Target阶段），检查额外卡组是否存在「红龙」并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以特殊召唤的「红龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的实际处理（Operation阶段），从额外卡组特殊召唤1只「红龙」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中第1只满足特殊召唤条件的「红龙」
	local tg=Duel.GetFirstMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将选中的「红龙」表侧表示特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
