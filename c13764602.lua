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
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,13764603)
	e2:SetCondition(c13764602.spcon)
	e2:SetTarget(c13764602.sptg)
	e2:SetOperation(c13764602.spop)
	c:RegisterEffect(e2)
end
-- 判断卡片是否为怪兽且属于「双天」系列并能加入手卡的过滤条件。
function c13764602.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x14f) and c:IsAbleToHand()
end
-- ①效果的发动时处理：从卡组筛选出可加入手卡的「双天」怪兽，若玩家选择发动，则由玩家选择1只加入手卡并展示给对方。
function c13764602.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足检索条件的「双天」怪兽。
	local g=Duel.GetMatchingGroup(c13764602.thfilter,tp,LOCATION_DECK,0,nil)
	-- 存在可检索的「双天」怪兽且玩家选择是时，继续执行检索。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(13764602,0)) then  --"是否要加入手卡？"
		-- 显示选择卡片的提示信息，要求玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「双天」怪兽以效果原因送往其持有者手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断怪兽是否为表侧表示且为「双天」效果怪兽的过滤条件。
function c13764602.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSetCard(0x14f)
end
-- ②效果的发动条件：我方场上有表侧表示且为「双天」效果怪兽的卡存在。
function c13764602.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方场上是否存在至少1只表侧表示的「双天」效果怪兽。
	return Duel.IsExistingMatchingCard(c13764602.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动合法性与对象检查：若处于对象检查阶段则校验指定对象是否在墓地且满足「双天」相关条件；若处于发动确认阶段则返回我方主要怪兽区有空位且能特殊召唤「双天魂衍生物」。
function c13764602.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13764602.spfilter(chkc,e,tp) end
	-- 发动条件检查：我方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：我方玩家是否能够特殊召唤「双天魂衍生物」（战士族·光·2星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 登记本次效果将进行特殊召唤的操作，供连锁/效果适用时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 登记本次效果将生成衍生物的操作，供连锁/效果适用时参考。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
-- ②效果处理：若我方仍有怪兽区空格且能够特殊召唤衍生物，则生成并特殊召唤「双天魂衍生物」。
function c13764602.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断我方主要怪兽区是否仍存在空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断我方玩家是否仍能够特殊召唤「双天魂衍生物」，若满足则继续。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,87669905,0x14f,TYPES_TOKEN_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 创建「双天魂衍生物」的衍生物（Token）。
		local token=Duel.CreateToken(tp,13764603)
		-- 将衍生物以表侧表示特殊召唤到我方场上。
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
	-- 将上述自肃效果注册到当前玩家，使其在回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定条件：只有融合怪兽才允许从额外卡组特殊召唤，其他额外卡组怪兽不能特殊召唤。
function c13764602.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
