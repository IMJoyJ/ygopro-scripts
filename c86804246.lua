--スーパーバグマン
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的「漏洞人X」「漏洞人Y」「漏洞人Z」从游戏中除外的场合可以表侧守备表示特殊召唤。只要这张卡在场上表侧表示存在，场上表侧攻击表示存在的全部怪兽的攻击力·守备力交换。「超级漏洞人」在场上只能有1只表侧表示存在。
function c86804246.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,86804246)
	-- 这张卡不能通常召唤。把自己墓地存在的「漏洞人X」「漏洞人Y」「漏洞人Z」从游戏中除外的场合可以表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(c86804246.spcon)
	e1:SetTarget(c86804246.sptg)
	e1:SetOperation(c86804246.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，场上表侧攻击表示存在的全部怪兽的攻击力·守备力交换。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SWAP_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c86804246.adfilter)
	c:RegisterEffect(e2)
end
-- 创建用于依次检测「漏洞人X」「漏洞人Y」「漏洞人Z」卡号的条件检查函数数组
c86804246.spchecks=aux.CreateChecks(Card.IsCode,{87526784,23915499,50319138})
-- 过滤墓地中属于「漏洞人X」「漏洞人Y」「漏洞人Z」且可以被除外的卡片
function c86804246.spfilter(c)
	return c:IsCode(87526784,23915499,50319138) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断：判断怪兽区域是否有空位，且墓地中是否存在可以各除外一张的「漏洞人X」「漏洞人Y」「漏洞人Z」
function c86804246.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有满足条件的「漏洞人X」「漏洞人Y」「漏洞人Z」卡片
	local g=Duel.GetMatchingGroup(c86804246.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 判断自己场上的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c86804246.spchecks)
end
-- 特殊召唤规则的Cost选择目标：从墓地中选择「漏洞人X」「漏洞人Y」「漏洞人Z」各一张，并将其暂存
function c86804246.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足条件的「漏洞人X」「漏洞人Y」「漏洞人Z」卡片
	local g=Duel.GetMatchingGroup(c86804246.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c86804246.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的Cost执行：将选中的「漏洞人X」「漏洞人Y」「漏洞人Z」从墓地中除外
function c86804246.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 攻守交换效果的过滤条件：筛选场上表侧攻击表示存在的怪兽
function c86804246.adfilter(e,c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
