--ジーナの蟲惑魔
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上盖放的1张陷阱卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
-- ③：自己的魔法与陷阱区域没有卡存在的场合，把墓地的这张卡除外，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c28868394.initial_effect(c)
	-- ①：把自己场上盖放的1张陷阱卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28868394,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28868394)
	e1:SetCost(c28868394.spcost)
	e1:SetTarget(c28868394.sptg)
	e1:SetOperation(c28868394.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不受「洞」通常陷阱卡以及「落穴」通常陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(c28868394.efilter)
	c:RegisterEffect(e2)
	-- ③：自己的魔法与陷阱区域没有卡存在的场合，把墓地的这张卡除外，以自己墓地1张「洞」通常陷阱卡或者「落穴」通常陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28868394,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,28868394)
	e3:SetCondition(c28868394.setcon)
	-- 设置③效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现除外自身作为代价）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c28868394.settg)
	e3:SetOperation(c28868394.setop)
	c:RegisterEffect(e3)
end
-- 定义①效果的代价筛选条件：里侧表示的陷阱卡且可以作为代价送去墓地。
function c28868394.costfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理函数：发动前检查是否存在符合条件的里侧陷阱卡；实际发动时选择1张并送去墓地作为代价。
function c28868394.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段确认自己魔陷区是否存在至少1张满足costfilter的里侧陷阱卡，以判定代价是否可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c28868394.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己魔陷区选择1张满足costfilter的里侧陷阱卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c28868394.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡送去墓地，作为发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动目标/条件判定函数：确认场上怪兽区有空位且此卡可以特殊召唤，并设置操作信息。
function c28868394.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查自己的主要怪兽区有空位，且这张卡可以以表侧表示特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息登记为特殊召唤此卡（CATEGORY_SPECIAL_SUMMON），供连锁与相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理函数：如果此卡仍与效果关联，则将其从手卡特殊召唤到场上。
function c28868394.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤，将这张卡以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的免疫判定函数：仅当发动效果的卡是「洞」或「落穴」系列的通常陷阱卡时，此卡不受其效果影响。
function c28868394.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- ③效果的发动条件过滤函数：判断魔陷区卡片是否位于非场地格（sequence<5），用于检测自己的魔法与陷阱区域是否有卡。
function c28868394.confilter(c)
	return c:GetSequence()<5
end
-- ③效果的发动条件：自己的魔法与陷阱区域没有卡存在。
function c28868394.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己魔陷区中满足confilter的卡数为0，若为0则条件成立。
	return Duel.GetMatchingGroupCount(c28868394.confilter,tp,LOCATION_SZONE,0,nil)==0
end
-- ③效果选择对象的筛选条件：墓地中满足「洞」或「落穴」系列、通常陷阱类型，且可以盖放到魔陷区的卡。
function c28868394.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsSSetable()
end
-- ③效果的发动目标判定与选择函数：检查墓地是否存在符合条件的「洞」/「落穴」通常陷阱卡作为对象；进行对象选择并设置操作信息。
function c28868394.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28868394.setfilter(chkc) end
	-- 发动时检查自己墓地是否存在1张满足setfilter且除自身外的卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c28868394.setfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 弹出选择提示，提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足setfilter的「洞」/「落穴」通常陷阱卡作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c28868394.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：该对象将离开墓地（CATEGORY_LEAVE_GRAVE），用于王家长眠之谷等相关检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果处理函数：取得对象卡，若仍与效果关联，则将其盖放到自己场上。
function c28868394.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡盖放到自己魔法与陷阱区域。
		Duel.SSet(tp,tc)
	end
end
