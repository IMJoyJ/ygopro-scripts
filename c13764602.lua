--阿吽の呼吸
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「双天」怪兽加入手卡。
-- ②：自己场上有「双天」效果怪兽存在的场合才能发动。在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c13764602.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，①：作为这张卡的发动时的效果处理，可以从卡组把1只「双天」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,13764602+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c13764602.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「双天」效果怪兽存在的场合才能发动。在自己场上把1只「双天魂衍生物」（战士族·光·2星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13764602,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,13764603)
	e2:SetCondition(c13764602.spcon)
	e2:SetTarget(c13764602.sptg)
	e2:SetOperation(c13764602.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为「双天」怪兽且能加入手卡。
function c13764602.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x14f) and c:IsAbleToHand()
end
-- ①效果的效果处理函数：检索卡组中可加入手卡的「双天」怪兽，由玩家选择是否将其中1只加入手卡并给对方确认。
function c13764602.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有符合条件的「双天」怪兽卡。
	local g=Duel.GetMatchingGroup(c13764602.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在可检索的「双天」怪兽，则询问玩家是否将1只加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13764602,0)) then  --"是否要加入手卡？"
		-- 向自己发送选择提示，提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「双天」怪兽以效果加入自己手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的「双天」怪兽给对方确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤函数：判断卡片是否为表侧表示的「双天」效果怪兽。
function c13764602.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0x14f)
end
-- ②效果的发动条件判定：检查自己怪兽区域是否存在至少1只表侧表示的「双天」效果怪兽。
function c13764602.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只表侧表示的「双天」效果怪兽。
	return Duel.IsExistingMatchingCard(c13764602.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标处理函数（可行性检测部分）：检查自己怪兽区域是否有空位且能特殊召唤「双天魂衍生物」。
function c13764602.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查自己怪兽区域是否至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己玩家是否能够特殊召唤战士族·光属性·2星·攻守0的「双天魂衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：预计进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置操作信息：预计生成并特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ②效果的效果处理函数（生成并特殊召唤衍生物部分）：若满足空位与特召条件，则在自己场上特殊召唤1只「双天魂衍生物」。
function c13764602.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次检查自己怪兽区域是否仍有可用空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己玩家当前是否仍能特殊召唤「双天魂衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 为自己生成1只「双天魂衍生物」卡片实体。
		local token=Duel.CreateToken(tp,13764603)
		-- 将生成的衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c13764602.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册一个直到回合结束时生效的全局限制效果，禁止自己从额外卡组特殊召唤非融合怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数：判定怪兽是否位于额外卡组且不是融合怪兽（满足则禁止特殊召唤）。
function c13764602.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
