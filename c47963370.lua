--マジシャン・オブ・カオス
-- 效果：
-- 「混沌形态」降临。
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：1回合1次，魔法·陷阱卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：仪式召唤的这张卡被战斗·效果破坏的场合才能发动。从手卡把「混沌之魔术师」以外的1只「混沌」仪式怪兽无视召唤条件特殊召唤。
function c47963370.initial_effect(c)
	-- 将「混沌形态」（21082832）加入卡片记述的相关卡片列表中
	aux.AddCodeList(c,21082832)
	c:EnableReviveLimit()
	-- 在怪兽区域和墓地时，这张卡的卡名当作「黑魔术师」使用
	aux.EnableChangeCode(c,46986414,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：1回合1次，魔法·陷阱卡的效果发动时，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47963370,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c47963370.descon)
	e2:SetTarget(c47963370.destg)
	e2:SetOperation(c47963370.desop)
	c:RegisterEffect(e2)
	-- ③：仪式召唤的这张卡被战斗·效果破坏的场合才能发动。从手卡把「混沌之魔术师」以外的1只「混沌」仪式怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c47963370.spcon)
	e3:SetTarget(c47963370.sptg)
	e3:SetOperation(c47963370.spop)
	c:RegisterEffect(e3)
end
-- 魔法·陷阱卡效果发动时破坏效果的发动条件判断
function c47963370.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 魔法·陷阱卡效果发动时破坏效果的靶向与发动检测
function c47963370.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以成为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏目标卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 魔法·陷阱卡效果发动时破坏效果的效果处理
function c47963370.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 仪式召唤的此卡被战斗·效果破坏特殊召唤效果的发动条件判断
function c47963370.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤手卡中满足特殊召唤条件的「混沌」仪式怪兽（排除自身且可无视召唤条件特殊召唤）
function c47963370.spfilter(c,e,tp)
	return c:IsSetCard(0xcf) and bit.band(c:GetType(),0x81)==0x81 and not c:IsCode(47963370) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的靶向与发动检测
function c47963370.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在满足条件的「混沌」仪式怪兽
		and Duel.IsExistingMatchingCard(c47963370.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤手卡怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的执行过程
function c47963370.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则处理终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中1只满足条件的「混沌」仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c47963370.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
