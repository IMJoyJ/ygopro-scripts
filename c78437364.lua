--剛鬼ザ・グレート・オーガ
-- 效果：
-- 「刚鬼」怪兽2只以上
-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力下降那怪兽的原本守备力数值。
-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡所连接区1只自己怪兽破坏。
function c78437364.initial_effect(c)
	-- 添加连接召唤手续：需要2只以上的「刚鬼」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力下降那怪兽的原本守备力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(c78437364.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合，可以作为代替把这张卡所连接区1只自己怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c78437364.desreptg)
	e2:SetOperation(c78437364.desrepop)
	c:RegisterEffect(e2)
end
-- 计算攻击力下降的数值，返回怪兽原本守备力的负值
function c78437364.atkval(e,c)
	local val=math.max(c:GetBaseDefense(),0)
	return val*-1
end
-- 过滤满足代替破坏条件的卡：自己场上、可被效果破坏且未确定被破坏的怪兽
function c78437364.repfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的Target函数，检查自身是否因战斗或效果破坏，并让玩家选择是否用所连接区的一只自己怪兽代替破坏
function c78437364.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetLinkedGroup()
		return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and g:IsExists(c78437364.repfilter,1,nil,e,tp)
	end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetLinkedGroup()
		-- 提示玩家选择要代替破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		local sg=g:FilterSelect(tp,c78437364.repfilter,1,1,nil,e,tp)
		e:SetLabelObject(sg:GetFirst())
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的Operation函数，执行将选中的代替卡片破坏的操作
function c78437364.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果和代替破坏的原因破坏选中的代替卡片
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
