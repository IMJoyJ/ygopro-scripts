--宝玉の祝福
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：选自己的魔法与陷阱区域最多2张「宝玉兽」怪兽卡特殊召唤，自己基本分回复那个原本攻击力合计的数值。
-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。自己卡组最上面的卡翻开，那是「宝玉兽」怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔陷区宝玉兽特召并回复基本分）和②效果（墓地被动诱发翻卡）
function s.initial_effect(c)
	-- ①：选自己的魔法与陷阱区域最多2张「宝玉兽」怪兽卡特殊召唤，自己基本分回复那个原本攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。自己卡组最上面的卡翻开，那是「宝玉兽」怪兽的场合，那只怪兽加入手卡或特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.flipcon)
	-- 把这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fliptg)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选自己魔法与陷阱区域表侧表示的、原本是怪兽卡的「宝玉兽」卡，且可以特殊召唤
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetSequence()<5
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备，检查怪兽区域是否有空位，以及魔法与陷阱区域是否存在可特殊召唤的「宝玉兽」怪兽卡，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否存在至少1张满足过滤条件的「宝玉兽」怪兽卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从魔法与陷阱区域特殊召唤至少1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	-- 设置回复生命值的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- ①效果的处理，特殊召唤魔法与陷阱区域最多2张「宝玉兽」怪兽卡，并回复那些怪兽原本攻击力合计数值的基本分
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从魔法与陷阱区域选择1到最多2张（且不超过可用怪兽格数量）满足条件的「宝玉兽」怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,0,1,math.min(ft,2),nil,e,tp)
	if #g==0 then return end
	-- 将选中的「宝玉兽」怪兽卡以表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 计算实际特殊召唤成功的怪兽的原本攻击力合计数值
	local atk=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
	-- 回复自己等同于上述原本攻击力合计数值的基本分
	Duel.Recover(tp,atk,REASON_EFFECT)
end
-- 过滤条件：检查是否有表侧表示的「宝玉兽」卡被放置在自己的魔法与陷阱区域
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- ②效果的发动条件，检查当前移动的卡片组中是否存在被放置在自己魔法与陷阱区域的「宝玉兽」卡
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动准备，检查卡组是否有卡，且是否可以加入手卡或特殊召唤
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否至少有1张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- 并且卡组最上方的卡可以加入手卡
		and (Duel.GetDecktopGroup(tp,1):IsExists(Card.IsAbleToHand,1,nil)
			-- 或者自己场上有怪兽空格且玩家可以进行特殊召唤
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp)
				-- 且自己未受到禁止将卡组卡片送去墓地的效果影响
				and not Duel.IsPlayerAffectedByEffect(tp,63060238)) end
end
-- ②效果的处理，翻开卡组最上面的卡，是「宝玉兽」怪兽的场合加入手卡或特殊召唤，否则送去墓地
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能将卡组顶端的卡送去墓地，不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认（翻开）自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的那张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 获取自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=tc:IsAbleToHand()
	local b2=ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	if tc:IsSetCard(0x1034) and tc:IsType(TYPE_MONSTER) and (b1 or b2) then
		-- 如果可以加入手卡，且（不能特殊召唤，或者玩家在“加入手卡”和“特殊召唤”的选项中选择了“加入手卡”）
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 禁用接下来的洗卡检测（因为卡片是从卡组顶端直接操作，不需要洗卡）
			Duel.DisableShuffleCheck()
			-- 将该卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else
			-- 禁用接下来的洗卡检测
			Duel.DisableShuffleCheck()
			-- 将该怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 禁用接下来的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将该卡作为被翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
