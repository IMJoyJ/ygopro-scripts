--夢魔鏡の魘魔－ネイロス
-- 效果：
-- 属性不同的「梦魔镜」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
-- ②：场地区域有「黯黑之梦魔镜」存在，怪兽的效果发动时才能发动。那个效果无效。
-- ③：场地区域有「圣光之梦魔镜」存在的场合，把这张卡解放才能发动。从额外卡组把1只「梦魔镜的天魔-涅伊洛斯」守备表示特殊召唤。这个效果在对方回合也能发动。
function c37678339.initial_effect(c)
	-- 记录该卡牌具有「黯黑之梦魔镜」、「圣光之梦魔镜」、「梦魔镜的天魔-涅伊洛斯」的卡名信息
	aux.AddCodeList(c,74665651,1050355,35187185)
	c:EnableReviveLimit()
	-- 设置融合召唤条件，使用2个满足过滤条件的「梦魔镜」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c37678339.ffilter,2,true)
	-- 只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
	-- 场地区域有「黯黑之梦魔镜」存在，怪兽的效果发动时才能发动。那个效果无效
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
	-- 场地区域有「圣光之梦魔镜」存在的场合，把这张卡解放才能发动。从额外卡组把1只「梦魔镜的天魔-涅伊洛斯」守备表示特殊召唤
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
-- 融合素材必须为「梦魔镜」卡组且属性不重复
function c37678339.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x131) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 效果发动时，确认该卡未因战斗破坏、发动的怪兽为怪兽类型、连锁效果可被无效、场地区域存在「黯黑之梦魔镜」
function c37678339.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsActiveType(TYPE_MONSTER)
		-- 场地区域存在「黯黑之梦魔镜」
		and Duel.IsChainDisablable(ev) and Duel.IsEnvironment(1050355,PLAYER_ALL,LOCATION_FZONE)
end
-- 设置效果处理时的操作信息，将被无效效果的目标设为eg
function c37678339.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为CATEGORY_DISABLE，表示该效果为使效果无效的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效
function c37678339.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 确认场地区域存在「圣光之梦魔镜」
function c37678339.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场地区域存在「圣光之梦魔镜」
	return Duel.IsEnvironment(74665651,PLAYER_ALL,LOCATION_FZONE)
end
-- 支付解放费用，将自身解放
function c37678339.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选额外卡组中可特殊召唤的「梦魔镜的天魔-涅伊洛斯」，并检查是否有足够的召唤位置
function c37678339.spfilter(c,e,tp,mc)
	return c:IsCode(35187185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外卡组召唤位置充足
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置特殊召唤操作信息，确认额外卡组存在符合条件的怪兽
function c37678339.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认额外卡组存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37678339.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息为CATEGORY_SPECIAL_SUMMON，表示该效果为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c37678339.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c37678339.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
