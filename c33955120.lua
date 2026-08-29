--黒薔薇と荊棘の魔女
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的植物族怪兽不会被效果破坏。
-- ③：这张卡在墓地存在的状态，场上的卡被效果破坏的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置同调召唤手续，注册同调召唤成功时从卡组·额外卡组精准堆墓、植物族怪兽效破抗性以及墓地诱发自我特召效果
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组·额外卡组各把最多1只植物族怪兽送去墓地。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
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
-- 判定卡片是否通过同调召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤可以送去墓地的植物族怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToGrave()
end
-- ①效果的发动条件与目标设置：判定卡组·额外卡组是否存在可送去墓地的植物族怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组·额外卡组中满足条件的植物族怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：从卡组·额外卡组将怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK)
end
-- 检查所选卡片是否来自不同位置（卡组与额外卡组各最多1张）
function s.lncheck(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- ①效果的处理：从卡组·额外卡组各把最多1只植物族怪兽送去墓地，并附加额外卡组特召限制
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 获取卡组·额外卡组中可送去墓地的植物族怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	-- 设置子卡片组选择校验函数（限制不同位置）
	aux.GCheckAdditional=s.lncheck
	-- 选择从卡组与额外卡组各最多1张植物族怪兽
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,2)
	-- 清除子卡片组校验函数
	aux.GCheckAdditional=nil
	if sg then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对自身玩家注册直到回合结束时不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤同调怪兽以外的怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 过滤场上的植物族怪兽
function s.indfilter(e,c)
	return c:IsRace(RACE_PLANT)
end
-- 过滤因效果被破坏且原本在场上的卡片
function s.sfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判定是否有场上的卡被效果破坏（自身除外）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ③效果的发动条件与目标设置：判定自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否有空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果的处理：将墓地的自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自身是否与连锁相关且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
