--BF－幻耀のスズリ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。除「黑羽-幻耀之苏德里」外的1张有「黑翼龙」的卡名记述的卡从卡组加入手卡。
-- ②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
function c70465810.initial_effect(c)
	-- 将「黑翼龙」的卡名注册为本卡效果中记载的卡名
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
	-- 这个卡名的②的效果1回合只能使用1次。②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
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
	-- 添加自定义活动计数器，用于记录玩家从额外卡组特殊召唤同调怪兽以外怪兽的次数
	Duel.AddCustomActivityCounter(70465810,ACTIVITY_SPSUMMON,c70465810.counterfilter)
end
-- 自定义计数器过滤条件：判定特殊召唤的怪兽是否不是来自额外卡组，或者是否是表侧表示的同调怪兽
function c70465810.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 检索条件过滤函数：除「黑羽-幻耀之苏德里」外，记载有「黑翼龙」卡名且可以加入手牌的卡
function c70465810.thfilter(c)
	-- 过滤条件判定：检查卡片是否记述了「黑翼龙」卡名、卡号不等于「黑羽-幻耀之苏德里」且能加入手牌
	return aux.IsCodeListed(c,9012916) and not c:IsCode(70465810) and c:IsAbleToHand()
end
-- 检索效果的目标检查与操作信息设置函数
function c70465810.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 阶段判定：检查卡组中是否存在符合条件的可以加入手牌的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70465810.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册操作信息：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，选择符合条件的卡加入手牌并给对方确认
function c70465810.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送系统提示：选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c70465810.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 解放限制过滤函数：确保被解放的怪兽离开场上后能留出可用的怪兽区域
function c70465810.rfilter(c,tp)
	-- 判定被解放的怪兽离开场上后，当前玩家场上的可用怪兽区域是否大于0
	return Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤效果发动代价的前半部分检查：可解放怪兽的存在判定及同调特招限制的检查
function c70465810.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定：检查当前玩家场上是否有满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c70465810.rfilter,1,nil,tp)
		-- 代价判定：检查当前玩家本回合内是否没有从额外卡组特殊召唤过同调怪兽以外的怪兽
		and Duel.GetCustomActivityCount(70465810,tp,ACTIVITY_SPSUMMON)==0 end
	-- 向玩家发送系统提示：选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从符合条件的怪兽中选择1只解放
	local g=Duel.SelectReleaseGroup(tp,c70465810.rfilter,1,1,nil,tp)
	-- 这个卡名的②的效果1回合只能使用1次。②：把自己场上1只怪兽解放才能发动（这个效果发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤）。在自己场上把1只「幻耀衍生物」（鸟兽族·调整·暗·2星·攻/守700）特殊召唤。那之后，自己受到700伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c70465810.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册玩家效果约束限制：本回合不能特殊召唤同调怪兽以外的额外怪兽
	Duel.RegisterEffect(e1,tp)
	-- 解放选择的怪兽作为效果发动的代价
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤限制过滤条件：限制从额外卡组召唤的非同调怪兽
function c70465810.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤与伤害效果的目标检查与操作信息设置函数
function c70465810.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 阶段判定：检查玩家是否可以特殊召唤暗属性·2星·攻/守700的鸟兽族衍生物怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,70465811,0,TYPES_TOKEN_MONSTER,700,700,2,RACE_WINDBEAST,ATTRIBUTE_DARK) end
	-- 注册操作信息：在场上特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 注册操作信息：包含特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 注册操作信息：玩家受到700点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,700)
end
-- 特殊召唤与伤害效果的执行函数，特殊召唤「幻耀衍生物」并给与玩家伤害
function c70465810.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行判断：若玩家怪兽区域已满无空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 执行判断：再次检查玩家是否能够特殊召唤「幻耀衍生物」
	if Duel.IsPlayerCanSpecialSummonMonster(tp,70465811,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,700,700,2,RACE_WINDBEAST,ATTRIBUTE_DARK) then
		-- 在场上创建「幻耀衍生物」的卡片数据
		local token=Duel.CreateToken(tp,70465811)
		-- 将创建的衍生物卡片以表侧表示特殊召唤至当前玩家场上，若成功则继续处理
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 中断效果处理，使前后的特殊召唤和受到伤害的动作不视为同时进行
			Duel.BreakEffect()
			-- 以效果处理给与当前玩家700点伤害
			Duel.Damage(tp,700,REASON_EFFECT)
		end
	end
end
