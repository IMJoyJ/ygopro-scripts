--海晶乙女アクア・アルゴノート
-- 效果：
-- 水属性怪兽2只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在额外怪兽区域存在，对方不能向其他怪兽攻击。
-- ②：以自己场上1只水属性怪兽和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
-- ③：对方回合，魔法·陷阱卡的效果在场上发动时才能发动。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤，那个发动的效果无效。
function c20934852.initial_effect(c)
	-- 为这张卡添加连接召唤手续，可用2～4只水属性怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,4)
	c:EnableReviveLimit()
	-- ①：只要这张卡在额外怪兽区域存在，对方不能向其他怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c20934852.atlcon)
	e1:SetValue(c20934852.atlimit)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只水属性怪兽和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
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
	-- ③：对方回合，魔法·陷阱卡的效果在场上发动时才能发动。选给这张卡装备的1张自己的「海晶少女」怪兽卡特殊召唤，那个发动的效果无效。
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
-- 判断本卡是否存在于额外怪兽区域（额外怪兽区域的格子序号大于4）；用于①效果的适用条件判定。
function c20934852.atlcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 设定不能被选择为攻击对象的过滤条件：除本卡自身以外的其他怪兽都不能被对方选择为攻击对象。
function c20934852.atlimit(e,c)
	return c~=e:GetHandler()
end
-- ②效果的对象选择过滤：自己场上的表侧表示水属性怪兽，且能被返回手牌。
function c20934852.thfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- ②效果的发动条件检查：场上是否存在1只满足thfilter的自己水属性怪兽以及1张对方场上可回手牌的卡；若为连锁处理时选择对象则返回false。
function c20934852.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1只表侧表示水属性且可回手牌的怪兽，作为取对象候选。
	if chk==0 then return Duel.IsExistingTarget(c20934852.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在1张可以回手牌的卡，作为取对象候选。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，要求玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只符合条件的表侧表示水属性怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c20934852.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次显示选择提示，用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以回手牌的卡作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本连锁将把两组对象（合计2张卡）返回持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果处理：取得连锁对象，过滤掉与效果失去联系的卡，将剩余对象返回持有者手牌。
function c20934852.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的对象卡集合（即发动②效果时选择的两张卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些对象卡以效果原因返回其持有者的手牌。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- ③效果的发动条件：对方回合，且当有魔法·陷阱卡的效果在场上发动且该连锁可被无效时才能发动。
function c20934852.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中效果发动的场所（位置）。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断当前是否为对方回合，且该效果发动的位置在魔法与陷阱区域（场上）。
	return Duel.GetTurnPlayer()==1-tp and bit.band(loc,LOCATION_SZONE)~=0
		-- 同时该发动效果的类型为魔法/陷阱，且该连锁效果可以被无效。
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- ③效果特殊召唤对象的过滤：装备于本卡的自己的「海晶少女」怪兽卡，且能够被特殊召唤。
function c20934852.spfilter(c,e,tp,ec)
	return c:IsSetCard(0x12b) and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件检查：自己主要怪兽区域有空位，且存在1张可特殊召唤的装备于本卡的「海晶少女」怪兽。
function c20934852.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在1张符合条件的「海晶少女」装备怪兽（装备于本卡且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c20934852.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：本连锁涉及从魔法与陷阱区域特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	-- 设置操作信息：本连锁涉及无效当前发动的效果（eg为触发连锁的卡）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果处理：选择1张装备于本卡的「海晶少女」怪兽特殊召唤，若特殊召唤成功，则无效被连锁的魔法/陷阱效果发动。
function c20934852.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的魔法与陷阱区域选择1张符合条件的「海晶少女」装备怪兽。
	local g=Duel.SelectMatchingCard(tp,c20934852.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,c)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上；若特殊召唤成功，则执行后续无效效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 无效当前连锁编号ev上的魔法/陷阱效果的发动。
		Duel.NegateEffect(ev)
	end
end
