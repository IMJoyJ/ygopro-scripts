--DDD極智王カオス・アポカリプス
-- 效果：
-- ←4 【灵摆】 4→
-- ①：把自己墓地2只「DD」怪兽除外才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- 「DDD 极智王 混沌默示神」的怪兽效果1回合只能使用1次，对方回合才能发动。
-- ①：这张卡在手卡·墓地存在的场合，以自己场上2张表侧表示的魔法·陷阱卡为对象才能发动。那些卡破坏，这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
function c83303851.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：把自己墓地2只「DD」怪兽除外才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83303851,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCost(c83303851.spcost)
	e1:SetTarget(c83303851.sptg)
	e1:SetOperation(c83303851.spop)
	c:RegisterEffect(e1)
	-- 「DDD 极智王 混沌默示神」的怪兽效果1回合只能使用1次，对方回合才能发动。①：这张卡在手卡·墓地存在的场合，以自己场上2张表侧表示的魔法·陷阱卡为对象才能发动。那些卡破坏，这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83303851,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,83303851)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(c83303851.descon)
	e2:SetTarget(c83303851.destg)
	e2:SetOperation(c83303851.desop)
	c:RegisterEffect(e2)
end
-- 过滤墓地中可作为发动代价除外的「DD」怪兽
function c83303851.cfilter(c)
	return c:IsSetCard(0xaf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 灵摆效果的Cost函数，用于检查和执行除外墓地2只「DD」怪兽的操作
function c83303851.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只可作为代价除外的「DD」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83303851.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地2只满足条件的「DD」怪兽
	local g=Duel.SelectMatchingCard(tp,c83303851.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 灵摆效果的Target函数，用于检查怪兽区域是否有空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c83303851.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果的Operation函数，执行将灵摆区域的这张卡特殊召唤的处理
function c83303851.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 怪兽效果的发动条件函数，限制只能在对方回合发动
function c83303851.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤场上表侧表示的魔法·陷阱卡
function c83303851.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 怪兽效果的Target函数，用于选择要破坏的2张表侧表示魔法·陷阱卡，并处理怪兽区域空格与选择对象位置的规则限制
function c83303851.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c83303851.filter(chkc) end
	-- 检查自己场上是否存在至少2张表侧表示的魔法·陷阱卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c83303851.filter,tp,LOCATION_ONFIELD,0,2,nil)
		-- 检查在怪兽区域没有空位时，选择的对象中是否包含足够数量的自己怪兽区域的卡，以确保破坏后能腾出空位进行特殊召唤
		and ct<=2 and (ct<=0 or Duel.IsExistingTarget(c83303851.filter,tp,LOCATION_MZONE,0,ct,nil))
		and not c:IsStatus(STATUS_CHAINING) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=nil
	if ct<=0 then
		-- 在怪兽区域有空位时，选择自己场上2张表侧表示的魔法·陷阱卡作为对象
		g=Duel.SelectTarget(tp,c83303851.filter,tp,LOCATION_ONFIELD,0,2,2,nil)
	elseif ct==1 then
		-- 在怪兽区域缺少1个空位时，先选择自己怪兽区域的1张表侧表示魔法·陷阱卡作为对象
		g=Duel.SelectTarget(tp,c83303851.filter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 提示玩家选择第2张要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择第2张表侧表示的魔法·陷阱卡作为对象
		local g2=Duel.SelectTarget(tp,c83303851.filter,tp,LOCATION_ONFIELD,0,1,1,g:GetFirst())
		g:Merge(g2)
	else
		-- 在怪兽区域缺少2个空位时，必须选择自己怪兽区域的2张表侧表示魔法·陷阱卡作为对象
		g=Duel.SelectTarget(tp,c83303851.filter,tp,LOCATION_MZONE,0,2,2,nil)
	end
	-- 设置破坏2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果的Operation函数，执行添加特殊召唤限制、破坏对象卡片以及将自身特殊召唤的处理
function c83303851.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那些卡破坏，这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c83303851.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册“直到回合结束时自己不是恶魔族怪兽不能特殊召唤”的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 如果对象卡片存在，则将其破坏，并检查是否成功破坏了至少1张卡
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 特殊召唤限制的过滤函数，限制只能特殊召唤恶魔族怪兽
function c83303851.splimit(e,c)
	return c:GetRace()~=RACE_FIEND
end
