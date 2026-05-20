--ダイナレスラー・バーリオニクス
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：只要自己场上有连接3以上的「恐龙摔跤手」怪兽存在，自己场上的表侧表示怪兽不受连接3以下的对方怪兽发动的效果影响。
function c80831552.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c80831552.sprcon)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有连接3以上的「恐龙摔跤手」怪兽存在，自己场上的表侧表示怪兽不受连接3以下的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c80831552.immcon)
	e2:SetValue(c80831552.efilter)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数：判断是否满足只有对方场上才有怪兽存在且自己场上有空位的条件
function c80831552.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 过滤条件：表侧表示、属于「恐龙摔跤手」系列且连接标记在3以上的怪兽
function c80831552.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x11a) and c:IsLinkAbove(3)
end
-- 免疫效果的生效条件：自己场上存在满足过滤条件的怪兽
function c80831552.immcon(e)
	-- 检查自己场上是否存在至少1张表侧表示且连接3以上的「恐龙摔跤手」怪兽
	return Duel.IsExistingMatchingCard(c80831552.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 免疫效果的过滤器：判定效果是否为对方玩家的、发动的、且来源怪兽是连接3以下的怪兽效果
function c80831552.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and re:IsActiveType(TYPE_MONSTER) and re:IsActivated() and re:GetHandler():IsLinkBelow(3)
end
