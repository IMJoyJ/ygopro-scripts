--トリックスター・ライブステージ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次，发动的回合，自己不是「淘气仙星」怪兽不能特殊召唤。
-- ①：这张卡的发动时，可以把自己墓地1只「淘气仙星」怪兽加入手卡。
-- ②：自己场上有「淘气仙星」连接怪兽存在的场合才能发动。把1只「淘气仙星衍生物」（天使族·光·1星·攻/守0）特殊召唤。
-- ③：对方的魔法与陷阱区域有卡存在的场合才能发动。把1只「淘气仙星衍生物」特殊召唤。
function c51208046.initial_effect(c)
	-- ①：这张卡的发动时，可以把自己墓地1只「淘气仙星」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51208046.target)
	e1:SetOperation(c51208046.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「淘气仙星」连接怪兽存在的场合才能发动。把1只「淘气仙星衍生物」（天使族·光·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51208046,1))  --"特殊召唤衍生物（自己场上有连接怪兽）"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,51208046)
	e2:SetCost(c51208046.cost)
	e2:SetCondition(c51208046.spcon1)
	e2:SetTarget(c51208046.sptg)
	e2:SetOperation(c51208046.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(51208046,2))  --"特殊召唤衍生物（对方魔陷区域有卡）"
	e3:SetCountLimit(1,51208047)
	e3:SetCondition(c51208046.spcon2)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录玩家在回合中进行的特殊召唤次数，以限制②③效果各只能使用一次。
	Duel.AddCustomActivityCounter(51208046,ACTIVITY_SPSUMMON,c51208046.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为「淘气仙星」卡组。
function c51208046.counterfilter(c)
	return c:IsSetCard(0xfb)
end
-- ③：对方的魔法与陷阱区域有卡存在的场合才能发动。把1只「淘气仙星衍生物」特殊召唤。
function c51208046.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家在当前回合是否已经进行过特殊召唤，若未进行则允许发动效果。
	if chk==0 then return Duel.GetCustomActivityCount(51208046,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止玩家特殊召唤怪兽的效果，该效果在结束阶段重置。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c51208046.splimit)
	-- 将上述禁止特殊召唤的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止非「淘气仙星」卡组的怪兽进行特殊召唤。
function c51208046.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xfb)
end
-- 检索满足条件的墓地「淘气仙星」怪兽的过滤函数。
function c51208046.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，指定将要从墓地加入手牌的卡。
function c51208046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要进行回手牌操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 发动①效果时，检索满足条件的墓地怪兽并询问是否加入手牌。
function c51208046.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的墓地「淘气仙星」怪兽组。
	local g=Duel.GetMatchingGroup(c51208046.thfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断是否有满足条件的墓地怪兽，并询问玩家是否发动效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51208046,0)) then  --"是否从墓地把1只「淘气仙星」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选定的卡加入手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断场上是否存在「淘气仙星」连接怪兽。
function c51208046.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xfb) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件，判断自己场上有「淘气仙星」连接怪兽存在。
function c51208046.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否存在满足条件的「淘气仙星」连接怪兽。
	return Duel.IsExistingMatchingCard(c51208046.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断对方魔法与陷阱区域是否有卡。
function c51208046.cfilter2(c)
	return c:GetSequence()<5
end
-- ③效果的发动条件，判断对方魔法与陷阱区域有卡存在。
function c51208046.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方魔法与陷阱区域是否存在至少一张卡。
	return Duel.IsExistingMatchingCard(c51208046.cfilter2,tp,0,LOCATION_SZONE,1,nil)
end
-- 设置②③效果的目标处理信息，包括召唤衍生物和特殊召唤操作。
function c51208046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有足够的场地空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「淘气仙星衍生物」。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 提示对方玩家已选择发动效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②③效果的处理函数，检查是否满足条件并执行特殊召唤。
function c51208046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否有足够的场地空间进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e)
		-- 检查玩家是否可以特殊召唤「淘气仙星衍生物」。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	-- 创建一张「淘气仙星衍生物」token。
	local token=Duel.CreateToken(tp,51208047)
	-- 将创建的衍生物特殊召唤到场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
