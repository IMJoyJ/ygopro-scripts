--クシャトリラ・シャングリラ
-- 效果：
-- 7星怪兽×2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段才能发动。从卡组把1只「俱舍怒威族」怪兽特殊召唤。
-- ②：每次对方的卡被里侧表示除外，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c73542331.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：等级7怪兽2只以上。
	aux.AddXyzProcedure(c,nil,7,2,nil,nil,99)
	-- ①：自己·对方的准备阶段才能发动。从卡组把1只「俱舍怒威族」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73542331,0))  --"从卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,73542331)
	e1:SetTarget(c73542331.sptg)
	e1:SetOperation(c73542331.spop)
	c:RegisterEffect(e1)
	-- ②：每次对方的卡被里侧表示除外，指定没有使用的主要怪兽区域或者魔法与陷阱区域1处才能发动。指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73542331,1))  --"指定区域不能使用"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(c73542331.lzcon)
	e2:SetTarget(c73542331.lztg)
	e2:SetOperation(c73542331.lzop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c73542331.reptg)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以特殊召唤的「俱舍怒威族」怪兽。
function c73542331.spfilter(c,e,tp)
	return c:IsSetCard(0x189) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测与效果处理确定。
function c73542331.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「俱舍怒威族」怪兽。
		and Duel.IsExistingMatchingCard(c73542331.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置在效果处理时将从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：从卡组特殊召唤1只「俱舍怒威族」怪兽。
function c73542331.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只可以特殊召唤的「俱舍怒威族」怪兽。
	local g=Duel.SelectMatchingCard(tp,c73542331.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤对方被里侧表示除外的卡。
function c73542331.cfilter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp) and c:IsPreviousControler(1-tp)
end
-- ②效果的发动条件检测：检查是否有对方的卡被里侧表示除外。
function c73542331.lzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c73542331.cfilter,1,nil,tp)
end
-- ②效果的发动检测与目标区域选择。
function c73542331.lztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有未使用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 加上对方场上的主要怪兽区域未使用的空格数。
		+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
		-- 加上自己场上的魔法与陷阱区域未使用的空格数。
		+Duel.GetLocationCount(tp,LOCATION_SZONE,PLAYER_NONE,0)
		-- 加上对方场上的魔法与陷阱区域未使用的空格数，并判断双方场上是否存在至少1个未使用的区域。
		+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
	-- 让玩家选择双方场上1处未使用的主要怪兽区域或魔法与陷阱区域。
	local dis=Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,0xe000e0)
	-- 将选择的区域标记保存为效果参数。
	Duel.SetTargetParam(dis)
	-- 在游戏界面上高亮提示被选择的区域。
	Duel.Hint(HINT_ZONE,tp,dis)
end
-- ②效果的效果处理：使指定的区域在这只怪兽表侧表示存在期间不能使用。
function c73542331.lzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标区域标记。
	local zone=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 指定的区域在这只怪兽表侧表示存在期间不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetValue(zone)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- ③效果的代替破坏处理：被战斗或效果破坏时，可以取除1个超量素材代替。
function c73542331.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否适用代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
