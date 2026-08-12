--九魂猫
-- 效果：
-- 9星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的其他怪兽不会成为对方的效果的对象。
-- ②：把这张卡1个超量素材取除，以自己墓地1只9星怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c28981598.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足条件的2只9星怪兽进行叠放
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的其他怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c28981598.tgtg)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 把这张卡1个超量素材取除，以自己墓地1只9星怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28981598,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28981598)
	e2:SetCost(c28981598.spcost)
	e2:SetTarget(c28981598.sptg)
	e2:SetOperation(c28981598.spop)
	c:RegisterEffect(e2)
end
-- 目标怪兽必须是从墓地特殊召唤且不是自身
function c28981598.tgtg(e,c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c~=e:GetHandler()
end
-- 支付效果代价，从自身取除1个超量素材
function c28981598.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选满足条件的怪兽：等级为9或控制者为对方，且可以特殊召唤
function c28981598.spfilter(c,e,tp)
	return (c:IsLevel(9) or c:IsControler(1-tp)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，确保场上存在可特殊召唤的怪兽
function c28981598.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c28981598.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c28981598.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽，从墓地选择符合条件的1只怪兽
	local g=Duel.SelectTarget(tp,c28981598.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果操作，将选中的怪兽特殊召唤到场上
function c28981598.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
