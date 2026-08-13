--Sin サイバー・エンド・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。从额外卡组把1只「电子终结龙」除外的场合才能特殊召唤。
-- ①：「罪」怪兽在场上只能有1只表侧表示存在。
-- ②：只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
function c1710476.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c1710476.uqfilter,LOCATION_MZONE)
	-- 从额外卡组把1只「电子终结龙」除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1710476.spcon)
	e1:SetTarget(c1710476.sptg)
	e1:SetOperation(c1710476.spop)
	c:RegisterEffect(e1)
	-- 没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c1710476.descon)
	c:RegisterEffect(e7)
	-- 只要这张卡在怪兽区域存在，其他的自己怪兽不能攻击宣言。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(c1710476.antarget)
	c:RegisterEffect(e8)
	-- 这张卡不能通常召唤。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件效果的判定值恒为假，使这张卡不能通过通常的特殊召唤方式出场，只能利用自身的EFFECT_SPSUMMON_PROC手续进行特殊召唤。
	e9:SetValue(aux.FALSE)
	c:RegisterEffect(e9)
end
-- 唯一性限制的过滤函数：根据是否适用「罪 领域」决定限制范围——若适用则仅限制同名卡（1710476）在场只能有1只，否则限制所有「罪」字段怪兽合计只能有1只表侧表示存在。
function c1710476.uqfilter(c)
	-- 检查该卡的控制者是否受到「罪 领域」的效果影响，以选择唯一性判定模式。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(1710476)
	else
		return c:IsSetCard(0x23)
	end
end
-- 特殊召唤素材筛选：从额外卡组选出卡号1546123（电子终结龙）且可以作为cost除外的卡。
function c1710476.spfilter(c)
	return c:IsCode(1546123) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤素材筛选（替代）：从自己场上或墓地选出具有48829461效果、可作为cost除外，且除外后自己仍有怪兽区空位的卡。
function c1710476.spfilter2(c,tp)
	-- 判定条件：该卡具有48829461效果、可作cost除外、且除外后仍有可用怪兽区。
	return c:IsHasEffect(48829461,tp) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：当自己怪兽区有空位且额外卡组存在可除外的「电子终结龙」，或场上/墓地存在可除外的替代素材时，允许进行特殊召唤；c为nil时用于规则检查返回true。
function c1710476.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己怪兽区是否有空位。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查额外卡组是否存在至少1张满足spfilter条件的「电子终结龙」。
		and Duel.IsExistingMatchingCard(c1710476.spfilter,tp,LOCATION_EXTRA,0,1,nil)
	-- 检查自己场上或墓地是否存在至少1张满足spfilter2条件的可除外素材。
	local b2=Duel.IsExistingMatchingCard(c1710476.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
	return b1 or b2
end
-- 特殊召唤手续的选择处理：构建可选素材组（额外卡组的「电子终结龙」以及场上/墓地的替代素材），提示玩家选择1张作为除外的代价；若选择替代素材则消耗其对应效果的使用次数。
function c1710476.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Group.CreateGroup()
	-- 仅当自己怪兽区有空位时，才把额外卡组的「电子终结龙」加入可选素材。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取额外卡组中所有满足spfilter的「电子终结龙」并合并到素材组。
		local g1=Duel.GetMatchingGroup(c1710476.spfilter,tp,LOCATION_EXTRA,0,nil)
		g:Merge(g1)
	end
	-- 获取自己场上和墓地中所有满足spfilter2的卡并合并到素材组。
	local g2=Duel.GetMatchingGroup(c1710476.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	g:Merge(g2)
	-- 向玩家显示“请选择要除外的卡”的提示，用于选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		if g2:IsContains(tc) then
			local te=tc:IsHasEffect(48829461,tp)
			te:UseCountLimit(tp)
		end
		return true
	else return false end
end
-- 特殊召唤手续的实际执行：从效果标签中取出选择的素材并除外，完成特殊召唤代价。
function c1710476.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将选择的素材卡以表侧表示除外，除外原因记为特殊召唤。
	Duel.Remove(tc,POS_FACEUP,REASON_SPSUMMON)
end
-- 自毁效果的触发条件：场上不存在任何表侧表示的场地魔法卡。
function c1710476.descon(e)
	-- 双方场地区域不存在表侧表示场地魔法卡时返回true，触发自毁。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 攻击宣言限制的过滤：限制对象为自己场上除这张卡以外的其他怪兽，即其他自己怪兽不能进行攻击宣言。
function c1710476.antarget(e,c)
	return c~=e:GetHandler()
end
