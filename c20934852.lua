--海晶乙女アクア・アルゴノート
-- 效果：
-- 水属性怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在额外怪兽区域存在，对方不能向其他怪兽攻击。
-- ②：以自己场上1只水属性怪兽和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
-- ③：对方回合，魔法·陷阱卡的效果在场上发动时才能发动。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤，那个发动的效果无效。
function c20934852.initial_effect(c)
	-- 添加连接召唤手续，要求使用2到4个水属性怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,4)
	c:EnableReviveLimit()
	-- 只要这张卡在额外怪兽区域存在，对方不能向其他怪兽攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c20934852.atlcon)
	e1:SetValue(c20934852.atlimit)
	c:RegisterEffect(e1)
	-- 以自己场上1只水属性怪兽和对方场上1张卡为对象才能发动。那些卡回到持有者手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20934852,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,20934852)
	e2:SetTarget(c20934852.thtg)
	e2:SetOperation(c20934852.thop)
	c:RegisterEffect(e2)
	-- 对方回合，魔法·陷阱卡的效果在场上发动时才能发动。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤，那个发动的效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20934852,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,20934853)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c20934852.discon)
	e3:SetTarget(c20934852.distg)
	e3:SetOperation(c20934852.disop)
	c:RegisterEffect(e3)
end
-- 判断该卡是否在额外怪兽区域（序列大于4）
function c20934852.atlcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 限制对方不能选择该卡为攻击对象
function c20934852.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 过滤满足条件的水属性怪兽（正面表示且能送入手牌）
function c20934852.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 设置效果发动时的检查条件，判断是否满足选择目标的条件
function c20934852.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c20934852.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在能送入手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1只自己场上的水属性怪兽
	local g1=Duel.SelectTarget(tp,c20934852.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1张对方场上的卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，指定将2张卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 处理效果发动，获取目标卡组并将其送入手牌
function c20934852.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将符合条件的卡送入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 判断是否满足发动效果的条件，包括对方回合、发动位置为魔法陷阱区、发动效果可被无效
function c20934852.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断发动位置是否为对方的魔法陷阱区域
	return Duel.GetTurnPlayer()==1-tp and bit.band(loc,LOCATION_SZONE)~=0
		-- 判断发动效果是否为魔法或陷阱类型且可被无效
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 过滤满足条件的「海晶少女」怪兽卡（已装备于该卡上且可特殊召唤）
function c20934852.spfilter(c,e,tp,ec)
	return c:IsSetCard(0x12b) and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的检查条件，判断是否满足选择目标的条件
function c20934852.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的「海晶少女」怪兽卡
		and Duel.IsExistingMatchingCard(c20934852.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置效果处理信息，指定将1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	-- 设置效果处理信息，指定将发动效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 处理效果发动，选择并特殊召唤1张「海晶少女」怪兽卡，同时使发动效果无效
function c20934852.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1张「海晶少女」怪兽卡
	local g=Duel.SelectMatchingCard(tp,c20934852.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,c)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
