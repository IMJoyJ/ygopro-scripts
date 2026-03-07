--D-HERO デッドリーガイ
-- 效果：
-- 「命运英雄」怪兽＋暗属性效果怪兽
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，丢弃1张手卡才能发动。从手卡·卡组把1只「命运英雄」怪兽送去墓地。那之后，自己墓地有「命运英雄」怪兽存在的场合，自己场上的全部「命运英雄」怪兽的攻击力直到回合结束时上升自己墓地的「命运英雄」怪兽数量×200。
function c30757127.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，要求一只满足融合种族为命运英雄且为暗属性效果怪兽的怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc008),c30757127.ffilter,true)
	-- ①：自己·对方回合，丢弃1张手卡才能发动。从手卡·卡组把1只「命运英雄」怪兽送去墓地。那之后，自己墓地有「命运英雄」怪兽存在的场合，自己场上的全部「命运英雄」怪兽的攻击力直到回合结束时上升自己墓地的「命运英雄」怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30757127,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,30757127)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	-- 设置效果发动条件为不能在伤害步骤发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c30757127.atkcost)
	e1:SetTarget(c30757127.atktg)
	e1:SetOperation(c30757127.atkop)
	c:RegisterEffect(e1)
end
c30757127.material_setcode=0xc008
-- 过滤函数，用于判断融合素材是否为暗属性且为效果怪兽
function c30757127.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_EFFECT)
end
-- 过滤函数，用于判断手牌中是否存在可丢弃且满足送去墓地条件的卡
function c30757127.cfilter(c,tp)
	-- 判断手牌中是否存在可丢弃的卡，并且存在满足送去墓地条件的卡
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c30757127.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c)
end
-- 过滤函数，用于判断卡是否为命运英雄卡组且为怪兽卡且能送去墓地
function c30757127.tgfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果的发动费用为丢弃一张手卡
function c30757127.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃手卡的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30757127.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 执行丢弃一张手卡的操作
	Duel.DiscardHand(tp,c30757127.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,tp)
end
-- 设置效果的发动目标为选择1只命运英雄怪兽送去墓地
function c30757127.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要处理送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数，用于判断场上是否为命运英雄怪兽且处于表侧表示
function c30757127.atkfilter(c)
	return c:IsSetCard(0xc008) and c:IsFaceup()
end
-- 过滤函数，用于判断墓地中的卡是否为命运英雄怪兽
function c30757127.ctfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER)
end
-- 设置效果的发动处理，包括选择并送去墓地、计算墓地命运英雄怪兽数量并提升场上命运英雄怪兽攻击力
function c30757127.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只命运英雄怪兽从手卡或卡组送去墓地
	local g=Duel.SelectMatchingCard(tp,c30757127.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡送去墓地且在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取场上所有表侧表示的命运英雄怪兽
		local tg=Duel.GetMatchingGroup(c30757127.atkfilter,tp,LOCATION_MZONE,0,nil)
		if tg:GetCount()<=0 then return end
		-- 计算墓地中命运英雄怪兽的数量
		local ct=Duel.GetMatchingGroupCount(c30757127.ctfilter,tp,LOCATION_GRAVE,0,nil)
		local tc=tg:GetFirst()
		while tc do
			-- 将攻击力提升效果应用到场上所有命运英雄怪兽上
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*200)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=tg:GetNext()
		end
	end
end
