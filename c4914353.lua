--スペース・インシュレイター
-- 效果：
-- 怪兽2只
-- ①：这张卡所连接区的怪兽的攻击力·守备力下降800。
-- ②：这张卡在墓地存在，自己场上有电子界族连接怪兽连接召唤时才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡不能作为连接素材，从场上离开的场合除外。这个效果在这张卡送去墓地的回合不能发动。
function c4914353.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，要求使用恰好2只怪兽作为连接素材（对应‘怪兽2只’）。
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：这张卡所连接区的怪兽的攻击力·守备力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c4914353.tgtg)
	e1:SetValue(-800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在，自己场上有电子界族连接怪兽连接召唤时才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡不能作为连接素材，从场上离开的场合除外。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4914353,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c4914353.spcon)
	e3:SetTarget(c4914353.sptg)
	e3:SetOperation(c4914353.spop)
	c:RegisterEffect(e3)
end
-- 用于①效果的取目标判断：仅当怪兽位于这张卡所连接区时才受到攻击力·守备力下降的影响。
function c4914353.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- ②效果的触发条件过滤：筛选出由自己控制、种族为电子界族、类型为连接怪兽且通过连接召唤成功特殊召唤的怪兽。
function c4914353.cfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- ②效果的发动条件：本次特殊召唤的怪兽中存在符合条件的电子界族连接怪兽，且满足‘这张卡送去墓地的回合不能发动’的限制。
function c4914353.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤成功的怪兽组中是否至少存在1只满足条件的电子界族连接怪兽，并且当前回合不是这张卡被送去墓地的回合。
	return eg:IsExists(c4914353.cfilter,1,nil,tp) and aux.exccon(e)
end
-- ②效果的发动时处理：计算本次成功连接召唤的电子界族连接怪兽所连接区的可特殊召唤区域，并确认这张卡能否以表侧表示特殊召唤到这些区域。
function c4914353.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=0
	local lg=eg:Filter(c4914353.cfilter,nil,tp)
	-- 遍历筛选出的电子界族连接怪兽，逐个获取其连接区位置。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetLinkedZone())
	end
	-- 发动时合法性检查：确认我方主要怪兽区仍有可用的空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 登记此效果的操作信息，标明本效果将特殊召唤1张卡（即墓地中的这张卡），以便其他卡进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：计算可特殊召唤区域，把这张卡从墓地特殊召唤到那只电子界族连接怪兽所连接区的自己场上；若成功，给这张卡附加‘不能作为连接素材’和‘离场时除外’的效果。
function c4914353.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=0
	local lg=eg:Filter(c4914353.cfilter,nil,tp)
	-- 在效果处理阶段，再次遍历符合条件的电子界族连接怪兽，合并它们的连接区作为特殊召唤的可用区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetLinkedZone())
	end
	-- 确认这张卡仍与效果关联、存在可用的连接区区域后，将其以表侧表示特殊召唤到对应格（分步特殊召唤中的一步）。
	if c:IsRelateToEffect(e) and zone~=0 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP,zone) then
		-- 这个效果特殊召唤的这张卡不能作为连接素材，从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e2,true)
	end
	-- 完成分步特殊召唤流程，触发特殊召唤成功后的时点。
	Duel.SpecialSummonComplete()
end
