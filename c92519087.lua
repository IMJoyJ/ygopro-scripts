--電脳堺狐－仙々
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：从场上送去墓地的卡不去墓地而除外。
-- ②：自己怪兽的攻击宣言时才能发动。选除外的1只自己或者对方的怪兽回到墓地。
-- ③：把这张卡以外的2只原本的种族·属性不同的怪兽从自己墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c92519087.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：从场上送去墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- ②：自己怪兽的攻击宣言时才能发动。选除外的1只自己或者对方的怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92519087,0))  --"选怪兽回到墓地"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,92519087)
	e2:SetCondition(c92519087.rtcon)
	e2:SetTarget(c92519087.rttg)
	e2:SetOperation(c92519087.rtop)
	c:RegisterEffect(e2)
	-- ③：把这张卡以外的2只原本的种族·属性不同的怪兽从自己墓地除外才能发动。这张卡从墓地特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92519087,1))  --"从墓地特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,92519088)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e3:SetCondition(aux.exccon)
	e3:SetCost(c92519087.spcost)
	e3:SetTarget(c92519087.sptg)
	e3:SetOperation(c92519087.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：除外状态且表侧表示的怪兽
function c92519087.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 效果②的发动条件：自己怪兽进行攻击宣言时
function c92519087.rtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at and at:IsControler(tp)
end
-- 效果②的发动准备：检查除外区是否存在表侧表示的怪兽，并设置送去墓地的操作信息
function c92519087.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查双方除外区是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92519087.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 设置效果处理信息：将双方除外区的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
-- 效果②的效果处理：选择除外的1只怪兽送去墓地
function c92519087.rtop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从双方除外区选择1只表侧表示的怪兽
	local g=Duel.SelectMatchingCard(tp,c92519087.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽送回墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
-- 过滤条件：选出的卡片组中，所有怪兽的原本种族和原本属性必须互不相同
function c92519087.fselect(g)
	return g:GetClassCount(Card.GetOriginalRace)==g:GetCount()
		and g:GetClassCount(Card.GetOriginalAttribute)==g:GetCount()
end
-- 过滤条件：墓地中可以作为除外Cost的怪兽
function c92519087.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果③的发动代价：从自己墓地将这张卡以外的2只原本种族·属性不同的怪兽除外
function c92519087.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中除这张卡以外、可作为除外Cost的怪兽卡组
	local g=Duel.GetMatchingGroup(c92519087.costfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return g:CheckSubGroup(c92519087.fselect,2,2) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c92519087.fselect,false,2,2)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 效果③的发动准备：检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c92519087.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动阶段，检查自己场上是否有可用怪兽区域，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的效果处理：将墓地的这张卡特殊召唤
function c92519087.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
