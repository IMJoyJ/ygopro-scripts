--絆醒師セームベル
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域有和这张卡相同等级的灵摆怪兽卡存在的场合才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡已在怪兽区域存在的状态，自己场上有其他怪兽特殊召唤的场合才能发动。和这张卡相同等级的1只怪兽从手卡特殊召唤。
function c46999905.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有和这张卡相同等级的灵摆怪兽卡存在的场合才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46999905,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,46999905)
	e1:SetCondition(c46999905.spcon)
	e1:SetTarget(c46999905.sptg)
	e1:SetOperation(c46999905.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡已在怪兽区域存在的状态，自己场上有其他怪兽特殊召唤的场合才能发动。和这张卡相同等级的1只怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46999905,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46999906)
	e2:SetCondition(c46999905.spcon2)
	e2:SetTarget(c46999905.sptg2)
	e2:SetOperation(c46999905.spop2)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于判断卡片是否与指定卡片等级相同
function c46999905.filter(c,mc)
	return c:IsLevel(mc:GetLevel())
end
-- 判断在自己的灵摆区域是否存在与该卡等级相同的灵摆怪兽卡
function c46999905.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否有满足条件的灵摆怪兽卡
	return Duel.IsExistingMatchingCard(c46999905.filter,tp,LOCATION_PZONE,0,1,e:GetHandler(),e:GetHandler())
end
-- 设置效果的目标处理，判断是否可以特殊召唤并获取要破坏的灵摆卡
function c46999905.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件（场上存在空位且该卡可被特殊召唤）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 获取自己灵摆区域中满足条件的第一张灵摆卡
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 设置操作信息，指定要破坏的卡片为灵摆卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置操作信息，指定要特殊召唤的卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果处理，先破坏灵摆卡再将自身特殊召唤
function c46999905.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己灵摆区域中满足条件的第一张灵摆卡
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 判断灵摆卡是否存在且成功破坏
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 将自身以正面表示方式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义一个过滤函数，用于判断卡片是否为指定玩家控制
function c46999905.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 判断发动效果的怪兽不是自己，并且有其他怪兽被特殊召唤
function c46999905.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c46999905.cfilter,1,nil,tp)
end
-- 定义一个过滤函数，用于判断手牌中是否有与指定等级相同的怪兽且可特殊召唤
function c46999905.spfilter2(c,e,tp,tc)
	return c:IsLevel(tc:GetLevel()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置第二个效果的目标处理，判断是否可以特殊召唤手牌中的怪兽
function c46999905.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c46999905.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c) end
	-- 设置操作信息，指定要特殊召唤的卡片为不确定数量（由选择决定）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 执行第二个效果处理，从手牌中选择并特殊召唤符合条件的怪兽
function c46999905.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	-- 判断场上是否还有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一张满足条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c46999905.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,c)
	if sg:GetCount()>0 then
		-- 将选中的怪兽以正面表示方式特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
