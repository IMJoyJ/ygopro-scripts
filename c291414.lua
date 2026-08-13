--想い集いし竜
-- 效果：
-- 自己对「集心龙」1回合只能有1次特殊召唤，把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
-- ①：这张卡的卡名只要在场上·墓地存在当作「救世龙」使用。
-- ②：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。自己场上有8星以上的龙族同调怪兽存在的场合，可以再从卡组把1只龙族·1星怪兽特殊召唤。
function c291414.initial_effect(c)
	c:SetSPSummonOnce(291414)
	-- 把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c291414.synlimit)
	c:RegisterEffect(e0)
	-- 为这张卡注册卡名变更效果，使其在场上·墓地存在时卡名当作「救世龙」使用。
	aux.EnableChangeCode(c,21159309,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。自己场上有8星以上的龙族同调怪兽存在的场合，可以再从卡组把1只龙族·1星怪兽特殊召唤。
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
-- 当这张卡被作为同调素材时，检查候选素材是否拥有「救世」卡名（0x3f），若不是则禁止将其作为同调素材（返回true表示不能使用）。
function c291414.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x3f)
end
-- 发动代价判定：这张卡在手中处于非公开状态（即抽到后尚未公开/展示）时满足展示给对方的条件，才能发动。
function c291414.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 发动目标判定：自己主要怪兽区有空位，且这张卡可以被当前效果特殊召唤时，效果可以发动。
function c291414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果处理包含特殊召唤这张卡1张的操作，供其他卡发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 追加效果的判定过滤：自己场上存在表侧表示、等级8以上、龙族、同调怪兽。
function c291414.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 追加特殊召唤的卡片过滤：卡组中满足龙族·1星且可以被特殊召唤的怪兽。
function c291414.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：先特殊召唤这张卡，成功后再根据条件决定是否从卡组追加特殊召唤龙族·1星怪兽。
function c291414.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关联，并且特殊召唤成功（返回值为0表示失败）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 在已经特殊召唤出这张卡后，再确认自己场上仍有可用怪兽区域，以判断能否进行追加特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在符合条件的8星以上龙族同调怪兽。
		and Duel.IsExistingMatchingCard(c291414.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断卡组中是否存在符合条件的龙族·1星怪兽可以被特殊召唤。
		and Duel.IsExistingMatchingCard(c291414.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否选择发动“从卡组把1只龙族·1星怪兽特殊召唤”的追加效果。
		and Duel.SelectYesNo(tp,aux.Stringid(291414,1)) then  --"是否从卡组把1只龙族·1星怪兽特殊召唤？"
		-- 中断当前连锁的效果处理，使后续的追加特殊召唤作为独立事件处理，避免错误时点。
		Duel.BreakEffect()
		-- 向玩家发送选择提示消息，要求其选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张满足条件的龙族·1星怪兽。
		local g=Duel.SelectMatchingCard(tp,c291414.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选择的龙族·1星怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
