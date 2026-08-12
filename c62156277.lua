--灰滅せし都の先懸
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方场上有攻击力2800以上的怪兽存在的场合，把这张卡解放，以对方场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果的特殊召唤规则和②效果的起动效果
function s.initial_effect(c)
	-- 将「灰灭之都 奥布西地暮」（卡号3055018）加入此卡的关联卡片密码列表中
	aux.AddCodeList(c,3055018)
	-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：对方场上有攻击力2800以上的怪兽存在的场合，把这张卡解放，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在表侧表示的「灰灭之都 奥布西地暮」
function s.spfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- ①效果特殊召唤规则的条件判定函数
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查双方的场地区域是否存在至少1张表侧表示的「灰灭之都 奥布西地暮」
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤函数：检查是否为表侧表示且攻击力在2800以上的怪兽
function s.thcheck(c)
	return c:IsFaceup() and c:IsAttackAbove(2800)
end
-- ②效果的发动条件判定函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧表示且攻击力在2800以上的怪兽
	return Duel.IsExistingMatchingCard(s.thcheck,tp,0,LOCATION_MZONE,1,nil)
end
-- ②效果的发动代价处理函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST+REASON_RELEASE)
end
-- ②效果的发动目标选择与效果分类注册函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以返回手牌的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示此效果包含将选中的1张卡送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的效果处理（操作）函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
