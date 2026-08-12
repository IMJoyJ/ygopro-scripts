--魔境のパラディオン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
-- ②：这张卡往连接怪兽所连接区的召唤·特殊召唤成功的场合，以自己场上1张「圣像骑士」卡和对方场上1张卡为对象才能发动。那些卡破坏。
function c55241609.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡往作为连接怪兽所连接区的自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,55241609+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55241609.spcon)
	e1:SetValue(c55241609.spval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡往连接怪兽所连接区的召唤·特殊召唤成功的场合，以自己场上1张「圣像骑士」卡和对方场上1张卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55241609,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,55241610)
	e2:SetCondition(c55241609.descon)
	e2:SetTarget(c55241609.destg)
	e2:SetOperation(c55241609.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件判定函数
function c55241609.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家tp场上所有连接怪兽所连接的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 判断在连接怪兽所连接的区域是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤规则的数值/位置设定函数
function c55241609.spval(e,c)
	-- 返回特殊召唤的表示形式（0表示默认，由SetTargetRange决定为守备表示）以及允许特殊召唤的区域（连接怪兽所连接的区域）
	return 0,Duel.GetLinkedZone(c:GetControler())
end
-- 效果②的发动条件判定函数，判断自身是否被召唤·特殊召唤到连接怪兽所连接的区域
function c55241609.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp场上处于连接状态的卡片组
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方场上处于连接状态的卡片组
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 过滤自己场上表侧表示的「圣像骑士」卡
function c55241609.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x116)
end
-- 效果②的对象选择与发动准备函数
function c55241609.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动效果的准备阶段，检查自己场上是否存在可以作为对象的表侧表示「圣像骑士」卡
	if chk==0 then return Duel.IsExistingTarget(c55241609.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且检查对方场上是否存在可以作为对象的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家tp发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「圣像骑士」卡作为效果对象
	local g1=Duel.SelectTarget(tp,c55241609.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 给玩家tp发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息，表示该效果将破坏选定的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②的执行函数
function c55241609.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果将这些卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
