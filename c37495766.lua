--R－ACEタービュランス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己墓地把2张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把最多4张「救援ACE队」速攻魔法·通常陷阱卡在自己场上盖放（同名卡最多1张）。
-- ③：自己场上的其他卡因对方的效果从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①特殊召唤、②盖放魔法陷阱、③破坏对方场上的卡
function s.initial_effect(c)
	-- ①：从自己墓地把2张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sscost)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把最多4张「救援ACE队」速攻魔法·通常陷阱卡在自己场上盖放（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：自己场上的其他卡因对方的效果从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏场上1张卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组（卡名是救援ACE队且能除外作为费用）
function s.costfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToRemoveAsCost()
end
-- 检查是否满足除外2张「救援ACE队」卡的条件，并选择2张卡除外
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2张「救援ACE队」卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查是否满足特殊召唤的条件
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索满足条件的卡片组（卡名是救援ACE队且能盖放）
function s.setfilter(c)
	return c:IsSetCard(0x18b) and c:IsSSetable()
		and (c:IsType(TYPE_QUICKPLAY) or c:GetType()==TYPE_TRAP)
end
-- 检查是否满足盖放魔法陷阱的条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的魔法陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放魔法陷阱的操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的魔法陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=4 then ft=4 end
	-- 检索满足条件的魔法陷阱卡
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 选择满足条件的魔法陷阱卡组
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选择的卡盖放到场上
			Duel.SSet(tp,sg)
		end
	end
end
-- 判断卡片是否因对方效果从场上离开
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- 判断是否满足触发破坏效果的条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置破坏效果的目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的一张卡作为破坏目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果的操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
