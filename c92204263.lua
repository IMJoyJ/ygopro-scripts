--紺碧の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
-- ②：1回合1次，以自己场上1只「机界骑士」怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
function c92204263.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：相同纵列有卡2张以上存在的场合，这张卡可以在那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,92204263+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c92204263.hspcon)
	e1:SetValue(c92204263.hspval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「机界骑士」怪兽为对象才能发动。那只自己怪兽的位置向其他的自己的主要怪兽区域移动。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92204263,0))  --"移动位置"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c92204263.seqtg)
	e2:SetOperation(c92204263.seqop)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断卡片所在的纵列是否有其他卡存在
function c92204263.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 特殊召唤规则的Condition函数，判断自己场上是否存在符合特殊召唤条件的纵列空格
function c92204263.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有所在纵列有2张以上卡片存在的卡片组
	local lg=Duel.GetMatchingGroup(c92204263.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片，计算它们所在的纵列在自己场上对应的主要怪兽区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断在这些符合条件的纵列区域中，自己场上是否有可用的主要怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的Value函数，计算并返回允许特殊召唤的区域
function c92204263.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有所在纵列有2张以上卡片存在的卡片组
	local lg=Duel.GetMatchingGroup(c92204263.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历这些卡片，计算它们所在的纵列在自己场上对应的主要怪兽区域
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 过滤函数，选择自己场上表侧表示的「机界骑士」怪兽
function c92204263.seqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10c)
end
-- 效果②的Target函数，进行发动条件判断、选择对象以及可行性检查
function c92204263.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92204263.seqfilter(chkc) end
	-- 在发动效果时，检查自己场上是否存在可以作为对象的表侧表示「机界骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c92204263.seqfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己场上是否有至少一个空余的主要怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end
	-- 提示玩家选择要移动位置的「机界骑士」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92204263,1))  --"请选择要移动位置的「机界骑士」怪兽"
	-- 选择自己场上1只表侧表示的「机界骑士」怪兽作为效果的对象
	Duel.SelectTarget(tp,c92204263.seqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的Operation函数，执行将选择的怪兽移动到其他主要怪兽区域的操作
function c92204263.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果、是否仍由自己控制，以及自己场上是否仍有空余的主要怪兽区域
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	-- 提示玩家选择要移动到的主要怪兽区域
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择自己场上1个空置的主要怪兽区域
	local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local nseq=math.log(s,2)
	-- 将目标怪兽移动到玩家选择的主要怪兽区域
	Duel.MoveSequence(tc,nseq)
end
