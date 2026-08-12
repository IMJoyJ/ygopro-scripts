--黒薔薇と荊棘の魔女
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的植物族怪兽不会被效果破坏。
-- ③：这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤程序、启用复活限制，并注册三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上的植物族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：该卡是同调召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的植物族怪兽（可送去墓地）
function s.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- 设置效果目标：从卡组和额外卡组选择最多2只植物族怪兽送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的植物族怪兽组（卡组+额外卡组）
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁操作信息：将目标卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- 检查所选卡是否来自不同区域（防止重复选择同一区域的卡）
function s.lncheck(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- 效果处理函数：选择并送去墓地植物族怪兽，并设置回合结束时不能从额外特殊召唤
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取满足条件的植物族怪兽组（卡组+额外卡组）
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	-- 设置额外检查条件为lncheck函数，用于确保所选卡来自不同区域
	aux.GCheckAdditional=s.lncheck
	-- 从满足条件的卡组中选择1~2张卡组成子组
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,2)
	-- 清除额外检查条件
	aux.GCheckAdditional=nil
	if sg:GetCount()>0 then
		-- 将所选卡组送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 设置回合结束时不能从额外特殊召唤的限制效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数：不能从额外特殊召唤非同调怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 影响对象过滤函数：仅影响场上的植物族怪兽
function s.indfilter(e,c)
	return c:IsRace(RACE_PLANT)
end
-- 过滤被效果破坏且在场上的卡
function s.sfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果发动条件：有被效果破坏的卡在场上，且不包含该卡本身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 设置效果目标：将该卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动效果：场上是否有空位且该卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将该卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将该卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否在连锁中且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
