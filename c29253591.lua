--ドラグニティ－クーゼ
-- 效果：
-- 把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作4星使用。
-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。
function c29253591.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c29253591.synlimit)
	c:RegisterEffect(e1)
	-- ①：把场上的这张卡作为同调素材的场合，可以把这张卡的等级当作4星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(c29253591.slevel)
	c:RegisterEffect(e2)
	-- ②：这张卡装备中的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29253591,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c29253591.sptg)
	e3:SetOperation(c29253591.spop)
	c:RegisterEffect(e3)
end
-- 定义限制判定函数：若候选同调素材不是「龙骑兵团」怪兽，则返回 true 使其不能作为同调素材，从而实现非「龙骑兵团」同调召唤不能使用的限制；若素材不存在则返回 false。
function c29253591.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x29)
end
-- 定义同调等级计算函数：返回的数值中，高16位为4，表示作为同调素材时等级当作4星；低16位保留原等级，供其他效果或判定使用。
function c29253591.slevel(e,c)
	-- 读取这张卡当前的等级，并经过系统上限保护处理，赋值给变量lv。
	local lv=aux.GetCappedLevel(e:GetHandler())
	return (4<<16)+lv
end
-- 发动效果的目标判定函数：取得效果所属卡c；在发动条件检查（chk==0）时，判断自己场上是否有空位、c是否处于装备状态且能够被特殊召唤，满足才允许发动。
function c29253591.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动条件检查（chk==0）时，确认自己主要怪兽区存在空格、这张卡有装备对象且能够被特殊召唤，全部满足才返回true以允许发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:GetEquipTarget() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 效果发动后登记操作信息：向系统宣告即将特殊召唤这张卡，数量为1，供其他卡的效果进行响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：若这张卡仍与当前效果保持关联（未因离场等原因失效），则将其特殊召唤；否则不处理。
function c29253591.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到tp的场上，召唤类型为0，由tp操作，并正常检查召唤条件与苏生限制（nocheck、nolimit均为false）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
