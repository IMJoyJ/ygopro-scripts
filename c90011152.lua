--おジャマ・カントリー
-- 效果：
-- 1回合1次，可以从手卡把1张名字带有「扰乱」的卡送去墓地，自己墓地存在的1只名字带有「扰乱」的怪兽特殊召唤。只要自己场上有名字带有「扰乱」的怪兽表侧表示存在，场上表侧表示存在的全部怪兽的原本的攻击力·守备力交换。
function c90011152.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从手卡把1张名字带有「扰乱」的卡送去墓地，自己墓地存在的1只名字带有「扰乱」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90011152,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c90011152.spcost)
	e2:SetTarget(c90011152.sptg)
	e2:SetOperation(c90011152.spop)
	c:RegisterEffect(e2)
	-- 只要自己场上有名字带有「扰乱」的怪兽表侧表示存在，场上表侧表示存在的全部怪兽的原本的攻击力·守备力交换。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCondition(c90011152.atcon)
	e3:SetCode(EFFECT_SWAP_BASE_AD)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「扰乱」卡片
function c90011152.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf)
end
-- 攻守交换效果的适用条件：自己场上存在表侧表示的「扰乱」怪兽
function c90011152.atcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「扰乱」怪兽
	return Duel.IsExistingMatchingCard(c90011152.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手牌中可以作为发动代价送去墓地的「扰乱」卡片
function c90011152.costfilter(c)
	return c:IsSetCard(0xf) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的代价处理函数：从手卡将1张「扰乱」卡片送去墓地
function c90011152.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查手牌中是否存在至少1张可以作为代价送去墓地的「扰乱」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c90011152.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择1张满足条件的「扰乱」卡片
	local g=Duel.SelectMatchingCard(tp,c90011152.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡片作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：墓地中可以特殊召唤的「扰乱」怪兽
function c90011152.filter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标处理函数：选择自己墓地1只「扰乱」怪兽为对象
function c90011152.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90011152.filter(chkc,e,tp) end
	-- 检查阶段：检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查阶段：检查自己墓地是否存在至少1只可以特殊召唤的「扰乱」怪兽
		and Duel.IsExistingTarget(c90011152.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的「扰乱」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c90011152.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：此效果包含特殊召唤分类，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的操作处理函数：将作为对象的怪兽特殊召唤
function c90011152.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
