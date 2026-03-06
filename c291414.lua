--想い集いし竜
-- 效果：
-- 自己对「集心龙」1回合只能有1次特殊召唤，把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
-- ①：这张卡的卡名只要在场上·墓地存在当作「救世龙」使用。
-- ②：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。自己场上有8星以上的龙族同调怪兽存在的场合，可以再从卡组把1只龙族·1星怪兽特殊召唤。
function c291414.initial_effect(c)
	c:SetSPSummonOnce(291414)
	-- 效果原文：自己对「集心龙」1回合只能有1次特殊召唤，把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c291414.synlimit)
	c:RegisterEffect(e0)
	-- 将此卡在场上或墓地时视为「救世龙」使用
	aux.EnableChangeCode(c,21159309,LOCATION_MZONE+LOCATION_GRAVE)
	-- 效果原文：②：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。自己场上有8星以上的龙族同调怪兽存在的场合，可以再从卡组把1只龙族·1星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(291414,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCost(c291414.spcost)
	e2:SetTarget(c291414.sptg)
	e2:SetOperation(c291414.spop)
	c:RegisterEffect(e2)
end
-- 当有非「救世」怪兽作为同调素材时，禁止其进行同调召唤
function c291414.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x3f)
end
-- 发动时必须确保此卡已被公开（非隐藏状态）
function c291414.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 判断是否满足特殊召唤条件
function c291414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：场上存在8星以上龙族同调怪兽
function c291414.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤条件：卡组中存在龙族1星怪兽
function c291414.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤并判断是否继续发动效果
function c291414.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡能被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在8星以上龙族同调怪兽
		and Duel.IsExistingMatchingCard(c291414.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断卡组中是否存在龙族1星怪兽
		and Duel.IsExistingMatchingCard(c291414.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否发动后续效果
		and Duel.SelectYesNo(tp,aux.Stringid(291414,1)) then  --"是否从卡组把1只龙族·1星怪兽特殊召唤？"
		-- 中断当前连锁处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择卡组中符合条件的龙族1星怪兽
		local g=Duel.SelectMatchingCard(tp,c291414.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
