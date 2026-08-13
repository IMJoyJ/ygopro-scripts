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
	-- 注册一个自定义特殊召唤活动计数器，统计本回合玩家进行过的非「淘气仙星」怪兽的特殊召唤次数，用于实现发动的回合不能特殊召唤非「淘气仙星」怪兽的自肃限制。
	Duel.AddCustomActivityCounter(51208046,ACTIVITY_SPSUMMON,c51208046.counterfilter)
end
-- 计数器过滤函数：被特殊召唤的怪兽若属于「淘气仙星」系列（setcode 0xfb）则返回true（不计入违规次数），否则返回false（会计入一次违规特殊召唤）。
function c51208046.counterfilter(c)
	return c:IsSetCard(0xfb)
end
-- ②③效果的发动代价：检查本回合非「淘气仙星」怪兽的特殊召唤次数为0后，为发动玩家附加一个直到回合结束的“不能特殊召唤非「淘气仙星」怪兽”的誓约效果。
function c51208046.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 无代价检查（chk==0）：仅当本回合非「淘气仙星」怪兽的特殊召唤次数为0时才允许发动效果。
	if chk==0 then return Duel.GetCustomActivityCount(51208046,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的②③的效果1回合各能使用1次，发动的回合，自己不是「淘气仙星」怪兽不能特殊召唤。①：这张卡的发动时，可以把自己墓地1只「淘气仙星」怪兽加入手卡。②：自己场上有「淘气仙星」连接怪兽存在的场合才能发动。把1只「淘气仙星衍生物」（天使族·光·1星·攻/守0）特殊召唤。③：对方的魔法与陷阱区域有卡存在的场合才能发动。把1只「淘气仙星衍生物」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c51208046.splimit)
	-- 将自肃效果e1作为场地效果注册，作用于发动玩家，使其不能特殊召唤非「淘气仙星」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：只要不是「淘气仙星」系列怪兽，就禁止其特殊召唤。
function c51208046.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xfb)
end
-- ①效果的检索过滤条件：从墓地选择怪兽卡、属于「淘气仙星」系列且能够加入手卡的卡。
function c51208046.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfb) and c:IsAbleToHand()
end
-- ①效果的发动目标：chk==0时直接允许发动，并设置操作信息为从墓地取1张卡加入手卡。
function c51208046.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理可能将1张卡从墓地加入手卡，供其他卡牌效果连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理：获取墓地可回收的「淘气仙星」怪兽，若存在且玩家选择是，则提示选择其中1张并加入手卡。
function c51208046.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有满足thfilter条件的「淘气仙星」怪兽。
	local g=Duel.GetMatchingGroup(c51208046.thfilter,tp,LOCATION_GRAVE,0,nil)
	-- 若存在符合条件的卡且玩家确认发动回收效果，则继续执行；否则不进行回收。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51208046,0)) then  --"是否从墓地把1只「淘气仙星」怪兽加入手卡？"
		-- 发送“选择要加入手牌的卡”的提示消息，要求玩家从候选卡中选1张。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入其持有者的手卡，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- ②效果的连接怪兽判定过滤条件：表侧表示、属于「淘气仙星」系列且为连接怪兽。
function c51208046.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xfb) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件：自己场上有满足cfilter1的「淘气仙星」连接怪兽存在。
function c51208046.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示「淘气仙星」连接怪兽。
	return Duel.IsExistingMatchingCard(c51208046.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- ③效果的对方魔陷区过滤条件：卡的sequence<5，即位于魔法与陷阱区域（不含场地魔法区）。
function c51208046.cfilter2(c)
	return c:GetSequence()<5
end
-- ③效果的发动条件：对方魔法与陷阱区域存在至少1张卡。
function c51208046.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方魔法与陷阱区域（序列号<5的区域）是否存在至少1张卡。
	return Duel.IsExistingMatchingCard(c51208046.cfilter2,tp,0,LOCATION_SZONE,1,nil)
end
-- ②③效果共同的发动目标判定：chk==0时检查自己主要怪兽区是否有空位，以及玩家能否特殊召唤「淘气仙星衍生物」。
function c51208046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区空位数大于0，确保有地方特殊召唤衍生物。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：玩家可以特殊召唤卡号51208047的「淘气仙星衍生物」（天使族·光·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 向对方玩家提示“选择了该效果”，并显示当前效果描述文本。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次效果涉及衍生物（token）的生成。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果涉及特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②③效果的处理：若主要怪兽区无空位、效果持有者已与效果失联或玩家无法特殊召唤衍生物，则中止；否则创建衍生物并特殊召唤。
function c51208046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若主要怪兽区没有空位或本卡已不关联该效果（如已离场），则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e)
		-- 处理前检查：若玩家当前不能特殊召唤「淘气仙星衍生物」，则处理失败。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,51208047,0xfb,TYPES_TOKEN_MONSTER,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	-- 创建1只卡号为51208047的「淘气仙星衍生物」token给tp玩家。
	local token=Duel.CreateToken(tp,51208047)
	-- 将衍生物以表侧表示形式特殊召唤到tp玩家场上（不检查召唤条件与苏生限制）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
