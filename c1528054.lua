--影法師トップハットヘア
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这张卡在这个回合不能作为连接素材。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 为卡片添加连接召唤手续，需要2只满足效果怪兽类型的怪兽作为连接素材
function s.initial_effect(c)
	-- 添加连接召唤手续，要求连接素材必须是效果怪兽类型
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 效果①：这张卡连接召唤的场合才能发动。把持有把自身作为怪兽特殊召唤效果的1张永续陷阱卡从卡组到自己场上盖放。这张卡在这个回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果③：魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：这张卡是通过连接召唤特殊召唤的
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选满足条件的永续陷阱卡，包括其类型、是否可盖放以及是否具有基础属性值
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
		and (c:GetOriginalLevel()>0
		or bit.band(c:GetOriginalRace(),0x3fffffff)~=0
		or bit.band(c:GetOriginalAttribute(),0x7f)~=0
		or c:GetBaseAttack()>0
		or c:GetBaseDefense()>0)
end
-- 效果①的发动条件检查：判断场上是否有足够的魔法陷阱区域以及卡组中是否存在符合条件的永续陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在符合条件的永续陷阱卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的发动处理：选择并盖放一张符合条件的永续陷阱卡，并使自身在本回合不能作为连接素材
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有足够的魔法陷阱区域以进行盖放
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		-- 从卡组中选择一张符合条件的永续陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的永续陷阱卡盖放到场上
			Duel.SSet(tp,tc)
		end
	end
	if c:IsRelateToEffect(e) then
		-- 使自身在本回合不能作为连接素材
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1,true)
	end
end
-- 判断目标怪兽是否为自身或自身战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 判断卡片是否从魔法陷阱区域被特殊召唤
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE)
end
-- 效果③的发动条件：不是自身被特殊召唤，且有从魔法陷阱区域特殊召唤的卡片
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(s.cfilter,1,nil)
end
-- 筛选魔法或陷阱类型的卡
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果③的发动处理：选择对方场上的魔法或陷阱卡进行破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在魔法或陷阱类型的卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的发动处理：破坏选中的魔法或陷阱卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
