--Kozmo－スリップライダー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只4星以下的「星际仙踪」怪兽特殊召唤。
function c94454495.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94454495,0))  --"魔法·陷阱卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c94454495.destg)
	e1:SetOperation(c94454495.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只4星以下的「星际仙踪」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94454495,1))  --"从卡组把「星际仙踪」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c94454495.spcon)
	e3:SetCost(c94454495.spcost)
	e3:SetTarget(c94454495.sptg)
	e3:SetOperation(c94454495.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上魔法、陷阱卡的条件函数
function c94454495.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①（破坏魔法·陷阱卡）的发动准备与目标选择
function c94454495.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c94454495.desfilter(chkc) end
	-- 检查场上是否存在至少1张可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c94454495.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c94454495.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①（破坏魔法·陷阱卡）的效果处理
function c94454495.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该对象卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②（被破坏送墓时特召）的发动条件：此卡因战斗或效果被破坏
function c94454495.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动代价：将墓地的这张卡除外
function c94454495.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将作为发动代价的墓地中的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤卡组中4星以下「星际仙踪」怪兽且能特殊召唤的条件函数
function c94454495.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（特召卡组怪兽）的发动准备与合法性检查
function c94454495.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足条件的「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c94454495.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②（特召卡组怪兽）的效果处理
function c94454495.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c94454495.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
