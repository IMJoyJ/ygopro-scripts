--刻まれし魔レクストレメンデ
-- 效果：
-- 「刻魔」融合怪兽＋融合·连接怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，丢弃1张手卡才能发动。从卡组·额外卡组把1只恶魔族·光属性怪兽送去墓地。
-- ②：这张卡只要有「刻魔」装备魔法卡装备，不受「刻魔」卡以外的卡的效果影响。
-- ③：这张卡被送去墓地的场合，以自己的墓地·除外状态的1张其他的「刻魔」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件、触发效果和免疫效果
function s.initial_effect(c)
	-- 设置融合召唤条件：需要1只「刻魔」融合怪兽和1只融合·连接怪兽作为融合素材
	aux.AddFusionProcFun2(c,s.mfilter1,s.mfilter2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合，丢弃1张手卡才能发动。从卡组·额外卡组把1只恶魔族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要有「刻魔」装备魔法卡装备，不受「刻魔」卡以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.imcon)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己的墓地·除外状态的1张其他的「刻魔」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤器1：筛选「刻魔」融合怪兽
function s.mfilter1(c)
	return c:IsFusionSetCard(0x1b0) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤器2：筛选融合·连接怪兽
function s.mfilter2(c)
	return c:IsFusionType(TYPE_FUSION+TYPE_LINK)
end
-- 效果条件：确认此卡是融合召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果费用：丢弃1张手卡
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选目标：恶魔族·光属性怪兽
function s.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果目标：从卡组·额外卡组选择1只恶魔族·光属性怪兽送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：将目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理：选择并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 装备魔法过滤器：筛选「刻魔」装备魔法
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b0) and c:IsAllTypes(TYPE_SPELL+TYPE_EQUIP)
end
-- 免疫效果条件：确认有「刻魔」装备魔法装备
function s.imcon(e)
	local sg=e:GetHandler():GetEquipGroup()
	return sg:IsExists(s.eqfilter,1,nil)
end
-- 免疫效果过滤器：排除非「刻魔」卡的效果
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x1b0)
end
-- 目标卡过滤器：筛选「刻魔」卡且在墓地或除外状态
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1b0) and c:IsAbleToHand()
end
-- 效果目标：选择1张自己的墓地或除外状态的其他「刻魔」卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「刻魔」卡
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler())
	-- 设置连锁操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选中的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且未受王家长眠之谷影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
