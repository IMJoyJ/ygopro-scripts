--マドルチェ・デセール
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以包含「魔偶甜点」怪兽的场上2只效果怪兽为对象才能发动。那些效果怪兽回到手卡·额外卡组。那之后，可以把回去的怪兽的原本攻击力合计以下的攻击力的1只「魔偶甜点」怪兽从手卡·额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己墓地的「魔偶甜点」卡回到卡组·额外卡组的场合才能发动。把这张卡作为自己场上1只超量怪兽的超量素材。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：以包含「魔偶甜点」怪兽的场上2只效果怪兽为对象才能发动。那些效果怪兽回到手卡·额外卡组。那之后，可以把回去的怪兽的原本攻击力合计以下的攻击力的1只「魔偶甜点」怪兽从手卡·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己墓地的「魔偶甜点」卡回到卡组·额外卡组的场合才能发动。把这张卡作为自己场上1只超量怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.matcon)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的效果怪兽（必须是效果怪兽且可以返回手牌或额外卡组）
function s.tdfilter(c,e)
	return c:IsType(TYPE_EFFECT) and (not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToHand() or c:IsAbleToExtra()) and c:IsCanBeEffectTarget(e)
		and c:IsFaceup()
end
-- 判断是否为「魔偶甜点」卡组
function s.filter(c,e)
	return c:IsSetCard(0x71)
end
-- 检查所选怪兽组中是否存在至少1只「魔偶甜点」怪兽
function s.gcheck(g)
	return g:IsExists(s.filter,1,nil)
end
-- 特殊召唤过滤函数，用于筛选满足条件的「魔偶甜点」怪兽（攻击力不超过目标怪兽总和）
function s.spfilter(c,e,tp,atk)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsAttackBelow(atk)
		-- 若目标怪兽在手牌，则判断是否有怪兽区空位
		and (c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp)>0
			-- 若目标怪兽在额外卡组，则判断是否有额外卡组召唤空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动处理函数，选择2只符合条件的怪兽作为对象并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上所有满足条件的效果怪兽
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将所选怪兽设置为连锁对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
end
-- 过滤函数，用于筛选与效果相关的怪兽（必须在场且为效果怪兽）
function s.rtfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ①效果的处理函数，将目标怪兽送回手牌并计算攻击力总和，然后询问是否特殊召唤
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选中的目标怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.rtfilter,nil,e)
	-- 将目标怪兽送回手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 获取实际操作的怪兽组
	local tg=Duel.GetOperatedGroup()
	if tg:GetCount()==0 then return end
	local sg=tg:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_EXTRA)
	local atk=sg:GetSum(Card.GetBaseAttack)
	-- 判断是否存在满足条件的「魔偶甜点」怪兽可特殊召唤，并询问玩家是否发动
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,atk) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的「魔偶甜点」怪兽进行特殊召唤
		local ssg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,atk)
		if ssg:GetCount()>0 then
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将所选怪兽特殊召唤到场上
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，用于筛选从墓地回到卡组或额外卡组的「魔偶甜点」卡
function s.cfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsSetCard(0x71) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的发动条件判断函数，检查是否有「魔偶甜点」卡从墓地回到卡组或额外卡组
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
-- 过滤函数，用于筛选场上的超量怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ②效果的目标设定函数，检查是否可以将此卡作为超量素材
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在可作为超量素材的超量怪兽且此卡可叠放
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end
	-- 设置操作信息，表示将此卡从墓地移除并作为超量素材
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数，选择目标超量怪兽并将其叠放此卡
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否存在可叠放此卡的超量怪兽
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) and c:IsCanOverlay() then
		-- 提示玩家选择要叠放的超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择目标超量怪兽
		local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		-- 将此卡叠放至目标超量怪兽上
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
