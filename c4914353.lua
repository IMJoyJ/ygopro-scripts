--スペース・インシュレイター
-- 效果：
-- 怪兽2只
-- ①：这张卡所连接区的怪兽的攻击力·守备力下降800。
-- ②：这张卡在墓地存在，自己场上有电子界族连接怪兽连接召唤时才能发动。这张卡在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的这张卡不能作为连接素材，从场上离开的场合除外。这个效果在这张卡送去墓地的回合不能发动。
function c4914353.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2个连接素材
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
-- 目标怪兽为连接区中的怪兽时才能发动效果
function c4914353.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 过滤条件：控制者为玩家、种族为电子界、类型为连接怪兽、召唤方式为连接召唤
function c4914353.cfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 条件判断：有电子界族连接怪兽成功特殊召唤，且这张卡不是在送去墓地的回合
function c4914353.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 有电子界族连接怪兽成功特殊召唤，且这张卡不是在送去墓地的回合
	return eg:IsExists(c4914353.cfilter,1,nil,tp) and aux.exccon(e)
end
-- 设置特殊召唤目标区域为连接怪兽所连接区的区域
function c4914353.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=0
	local lg=eg:Filter(c4914353.cfilter,nil,tp)
	-- 遍历连接怪兽组以获取其连接区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetLinkedZone())
	end
	-- 判断是否有足够的场上空位进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置连锁操作信息，确定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果，包括设置不能作为连接素材和离场时除外的效果
function c4914353.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=0
	local lg=eg:Filter(c4914353.cfilter,nil,tp)
	-- 遍历连接怪兽组以获取其连接区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetLinkedZone())
	end
	-- 判断是否满足特殊召唤条件：卡片存在、有可用区域、特殊召唤步骤成功
	if c:IsRelateToEffect(e) and zone~=0 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP,zone) then
		-- 设置效果：特殊召唤的这张卡不能作为连接素材
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		-- 设置效果：从场上离开时除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
