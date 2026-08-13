--夢魔鏡の魘魔－ネイロス
-- 效果：
-- 属性不同的「梦魔镜」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
-- ②：场地区域有「黯黑之梦魔镜」存在，怪兽的效果发动时才能发动。那个效果无效。
-- ③：场地区域有「圣光之梦魔镜」存在的场合，把这张卡解放才能发动。从额外卡组把1只「梦魔镜的天魔-涅伊洛斯」守备表示特殊召唤。这个效果在对方回合也能发动。
function c37678339.initial_effect(c)
	-- 记录本卡效果文中提到的相关卡名：74665651「圣光之梦魔镜」、1050355「黯黑之梦魔镜」、35187185「梦魔镜的天魔-涅伊洛斯」，以便效果处理和关联判定时识别这些卡。
	aux.AddCodeList(c,74665651,1050355,35187185)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只满足ffilter条件的怪兽作为融合素材，即“属性不同的「梦魔镜」怪兽×2”，从而可以融合召唤这张卡。
	aux.AddFusionProcFunRep(c,c37678339.ffilter,2,true)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：场地区域有「黯黑之梦魔镜」存在，怪兽的效果发动时才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37678339,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37678339)
	e2:SetCondition(c37678339.discon)
	e2:SetTarget(c37678339.distg)
	e2:SetOperation(c37678339.disop)
	c:RegisterEffect(e2)
	-- ③：场地区域有「圣光之梦魔镜」存在的场合，把这张卡解放才能发动。从额外卡组把1只「梦魔镜的天魔-涅伊洛斯」守备表示特殊召唤。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37678339,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37678340)
	e3:SetCondition(c37678339.spcon)
	e3:SetCost(c37678339.spcost)
	e3:SetTarget(c37678339.sptg)
	e3:SetOperation(c37678339.spop)
	c:RegisterEffect(e3)
end
-- 融合素材筛选函数：检查素材怪兽是否为「梦魔镜」系列（setcode 0x131），且其属性不能与已选的融合素材中任意一张的属性相同，从而保证2只素材属性不同。
function c37678339.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x131) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- ②效果的发动条件：这张卡不在战斗破坏确定状态；连锁中的效果为怪兽效果；该连锁效果可以被无效；且场地区存在「黯黑之梦魔镜」（1050355）。
function c37678339.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		-- 进一步要求：当前连锁的效果能够被无效，并且场地区公开存在「黯黑之梦魔镜」（1050355），两者均满足时②才可发动。
		and Duel.IsChainDisablable(ev) and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- ②的发动目标阶段：本效果不取对象，因此只要满足发动条件即可合法发动；发动时登记将无效化连锁上的怪兽效果。
function c37678339.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：登记本次处理将无效化连锁上的1个怪兽效果（eg），效果分类为CATEGORY_DISABLE，供系统与其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：直接将当前连锁中编号为ev的那个怪兽效果无效。
function c37678339.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁编号ev对应的效果无效，实现“那个效果无效”。
	Duel.NegateEffect(ev)
end
-- ③效果的发动条件：当前场地区存在「圣光之梦魔镜」（74665651）时才能发动。
function c37678339.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场地区是否有卡号74665651（「圣光之梦魔镜」），与控制者无关，且只在场地魔法区域判定。
	return Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- ③的发动代价：将这张卡自身解放；先检查是否可以解放，可以则支付解放代价。
function c37678339.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以REASON_COST（代价）原因解放效果持有者（这张卡本身）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤目标的筛选条件：目标必须是「梦魔镜的天魔-涅伊洛斯」（35187185），能够被正常特殊召唤，并且解放这张卡后仍有足够的额外卡组怪兽可用的特殊召唤区域。
function c37678339.spfilter(c,e,tp,mc)
	return c:IsCode(35187185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认解放这张卡之后，额外卡组怪兽特殊召唤区域仍有空格（GetLocationCountFromEx>0）。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ③的发动目标阶段：检查额外卡组是否存在满足spfilter的目标（即「梦魔镜的天魔-涅伊洛斯」）；存在则登记特殊召唤操作。
function c37678339.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：额外卡组中至少存在1张满足spfilter的卡且区域足够，否则③不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37678339.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：登记本次处理将从额外卡组特殊召唤1只怪兽；因目标在处理时选择，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理：选择要特殊召唤的「梦魔镜的天魔-涅伊洛斯」，并将其以表侧守备表示特殊召唤。
function c37678339.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示消息，让当前玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1张满足spfilter条件的「梦魔镜的天魔-涅伊洛斯」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c37678339.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 then
		-- 将选择的「梦魔镜的天魔-涅伊洛斯」以表侧守备表示特殊召唤到自己的场上（sumtype=0，不限定特殊召唤方式）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
