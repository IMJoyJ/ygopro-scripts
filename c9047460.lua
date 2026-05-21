--BF－隠れ蓑のスチーム
-- 效果：
-- 「黑羽-隐身蓑之斯蒂姆」的②的效果在决斗中只能使用1次。
-- ①：表侧表示的这张卡从场上离开的场合发动。在自己场上把1只「蒸汽衍生物」（水族·风·1星·攻/守100）特殊召唤。
-- ②：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。把这个效果特殊召唤的这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是「黑羽」怪兽。
function c9047460.initial_effect(c)
	-- ①：表侧表示的这张卡从场上离开的场合发动。在自己场上把1只「蒸汽衍生物」（水族·风·1星·攻/守100）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9047460,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c9047460.tkcon)
	e1:SetTarget(c9047460.tktg)
	e1:SetOperation(c9047460.tkop)
	c:RegisterEffect(e1)
	-- 「黑羽-隐身蓑之斯蒂姆」的②的效果在决斗中只能使用1次。②：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9047460,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,9047460+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(c9047460.spcost)
	e2:SetTarget(c9047460.sptg)
	e2:SetOperation(c9047460.spop)
	c:RegisterEffect(e2)
end
-- 检查这张卡离场前是否为表侧表示
function c9047460.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 衍生物特殊召唤效果的发动准备，设置操作信息
function c9047460.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：包含特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 衍生物特殊召唤效果的处理：在自己场上特殊召唤1只「蒸汽衍生物」
function c9047460.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物怪兽
	if Duel.IsPlayerCanSpecialSummonMonster(tp,9047461,0,TYPES_TOKEN_MONSTER,100,100,3,RACE_AQUA,ATTRIBUTE_WIND) then
		-- 创建「蒸汽衍生物」的卡片数据
		local token=Duel.CreateToken(tp,9047461)
		-- 将创建的衍生物以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可解放怪兽的条件：若怪兽区已满，则必须解放主要怪兽区的怪兽以腾出位置
function c9047460.cfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
-- 墓地特殊召唤效果的代价处理：解放自己场上的1只怪兽
function c9047460.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查阶段：判断是否满足解放1只怪兽以进行特殊召唤的条件
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c9047460.cfilter,1,nil,ft,tp) end
	-- 让玩家选择1只满足条件的怪兽进行解放
	local sg=Duel.SelectReleaseGroup(tp,c9047460.cfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽作为代价解放
	Duel.Release(sg,REASON_COST)
end
-- 墓地特殊召唤效果的发动准备：检查自身是否可以特殊召唤，并设置操作信息
function c9047460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的处理：将这张卡特殊召唤，并对其适用同调素材限制的效果
function c9047460.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其表侧表示特殊召唤，成功时适用同调素材限制
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 把这个效果特殊召唤的这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是「黑羽」怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetTarget(c9047460.synlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 限制同调素材的条件：其他的同调素材怪兽必须全部是「黑羽」怪兽
function c9047460.synlimit(e,c)
	return c:IsSetCard(0x33)
end
