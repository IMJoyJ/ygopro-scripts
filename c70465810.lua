--BF－幻耀のスズリ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。除「黑羽-幻耀之苏德里」外的1张有「黑翼龙」的卡名记述的卡从卡组加入手卡。
-- ②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
function c70465810.initial_effect(c)
	-- 注册卡片记述了「黑翼龙」卡名的信息
	aux.AddCodeList(c,9012916)
	-- ①：这张卡召唤时才能发动。除「黑羽-幻耀之苏德里」外的1张有「黑翼龙」的卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70465810,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c70465810.thtg)
	e1:SetOperation(c70465810.thop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70465810,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,70465810)
	e2:SetCost(c70465810.spcost)
	e2:SetTarget(c70465810.sptg)
	e2:SetOperation(c70465810.spop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于检测本回合是否特殊召唤过非同调怪兽
	Duel.AddCustomActivityCounter(70465810,ACTIVITY_SPSUMMON,c70465810.counterfilter)
end
-- 计数器过滤函数：非额外卡组特殊召唤的怪兽，或者是同调怪兽
function c70465810.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO)
end
-- 检索过滤函数：卡组中记述了「黑翼龙」卡名且不是「黑羽-幻耀之苏德里」的可加入手牌的卡
function c70465810.thfilter(c)
	-- 检查卡片是否记述了「黑翼龙」且不是「黑羽-幻耀之苏德里」并且可以加入手牌
	return aux.IsCodeListed(c,9012916) and not c:IsCode(70465810) and c:IsAbleToHand()
end
-- 效果①的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c70465810.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70465810.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组选择1张符合条件的卡加入手牌并给对方确认
function c70465810.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c70465810.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 解放过滤函数：检查怪兽被解放后是否能空出可用的怪兽区域
function c70465810.rfilter(c,tp)
	-- 检查将该怪兽解放后，自己场上的怪兽区域空位数是否大于0
	return Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的发动代价，检查是否能解放怪兽、是否满足额外特招限制，并执行解放和注册誓约效果
function c70465810.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放且解放后能空出怪兽区域的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c70465810.rfilter,1,nil,tp)
		-- 检查本回合自己是否没有从额外卡组特殊召唤过非同调怪兽
		and Duel.GetCustomActivityCount(70465810,tp,ACTIVITY_SPSUMMON)==0 end
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足解放条件的怪兽
	local g=Duel.SelectReleaseGroup(tp,c70465810.rfilter,1,1,nil,tp)
	-- ②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c70465810.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该誓约效果，限制玩家本回合不能从额外卡组特殊召唤同调怪兽以外的怪兽
	Duel.RegisterEffect(e1,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 限制函数：禁止从额外卡组特殊召唤非同调怪兽
function c70465810.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 效果②的发动准备，检查是否能特殊召唤衍生物，并设置特殊召唤、衍生物和伤害的操作信息
function c70465810.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以特殊召唤指定的「幻耀衍生物」
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,70465811,0,TYPES_TOKEN_MONSTER,700,700,2,RACE_WINDBEAST,ATTRIBUTE_DARK) end
	-- 设置操作信息：产生衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：给与玩家700点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,700)
end
-- 效果②的效果处理，在自己场上特殊召唤1只「幻耀衍生物」，之后自己受到700点伤害
function c70465810.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域空位数，若没有空位则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次检查是否可以特殊召唤指定的「幻耀衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,70465811,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,700,700,2,RACE_WINDBEAST,ATTRIBUTE_DARK) then
		-- 在后台创建「幻耀衍生物」的卡片数据
		local token=Duel.CreateToken(tp,70465811)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上，并检查是否特殊召唤成功
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 中断当前效果处理，使后续的伤害处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 因效果给与自己700点伤害
			Duel.Damage(tp,700,REASON_EFFECT)
		end
	end
end
