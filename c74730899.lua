--燃料電池メン
-- 效果：
-- 自己场上有名字带有「电池人」的怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。1回合1次，可以把这张卡以外的自己场上存在的1只名字带有「电池人」的怪兽解放，选择对方场上存在的1张卡回到持有者手卡。
function c74730899.initial_effect(c)
	-- 自己场上有名字带有「电池人」的怪兽表侧表示2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c74730899.spcon)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡以外的自己场上存在的1只名字带有「电池人」的怪兽解放，选择对方场上存在的1张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74730899,0))  --"返回手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c74730899.retcost)
	e2:SetTarget(c74730899.rettg)
	e2:SetOperation(c74730899.retop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「电池人」怪兽
function c74730899.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x28)
end
-- 判断自身特殊召唤的条件是否满足（怪兽区域有空位且自己场上存在2只以上表侧表示的「电池人」怪兽）
function c74730899.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少2只表侧表示的「电池人」怪兽
		and Duel.IsExistingMatchingCard(c74730899.spfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 处理起动效果的发动代价（解放自身以外的自己场上1只「电池人」怪兽）
function c74730899.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否存在除自身以外可解放的「电池人」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x28) end
	-- 让玩家选择自己场上除自身以外的1只「电池人」怪兽作为解放的代价
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x28)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 处理起动效果的发动准备（选择对方场上1张卡作为效果对象，并设置操作信息）
function c74730899.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 在效果发动准备阶段，检查对方场上是否存在可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息为“将1张卡送回手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理起动效果的效果（将作为对象的卡送回持有者手牌）
function c74730899.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
