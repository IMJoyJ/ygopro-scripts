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
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c28868394.settg)
	e3:SetOperation(c28868394.setop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否有盖放的陷阱卡可以作为费用送去墓地
function c28868394.costfilter(c)
	return c:IsFacedown() and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 效果处理：选择场上1张盖放的陷阱卡送去墓地
function c28868394.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在至少1张盖放的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c28868394.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1张盖放的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c28868394.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：检查是否可以特殊召唤此卡
function c28868394.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足条件：场上存在空位且此卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：执行特殊召唤
function c28868394.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果过滤函数：判断效果是否影响「洞」或「落穴」陷阱卡
function c28868394.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89)
end
-- 过滤函数：检查场上是否有非额外区域的卡
function c28868394.confilter(c)
	return c:GetSequence()<5
end
-- 效果处理：检查魔法与陷阱区域是否为空
function c28868394.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上魔法与陷阱区域是否为空
	return Duel.GetMatchingGroupCount(c28868394.confilter,tp,LOCATION_SZONE,0,nil)==0
end
-- 过滤函数：检查墓地中的陷阱卡是否为「洞」或「落穴」
function c28868394.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x4c,0x89) and c:IsSSetable()
end
-- 效果处理：选择墓地中的「洞」或「落穴」陷阱卡
function c28868394.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28868394.setfilter(chkc) end
	-- 检查是否满足条件：墓地存在至少1张「洞」或「落穴」陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c28868394.setfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择墓地中的「洞」或「落穴」陷阱卡
	local g=Duel.SelectTarget(tp,c28868394.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：准备将卡盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：执行盖放操作
function c28868394.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡盖放到场上
		Duel.SSet(tp,tc)
	end
end
