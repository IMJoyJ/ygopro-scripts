--超重武者オタス－K
-- 效果：
-- ①：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡丢弃，以进行战斗的怪兽以外的自己场上1只「超重武者」怪兽为对象才能发动。那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
function c44891812.initial_effect(c)
	-- 效果原文内容：①：自己墓地没有魔法·陷阱卡存在的场合，自己的守备表示怪兽和对方怪兽进行战斗的伤害计算时把这张卡从手卡丢弃，以进行战斗的怪兽以外的自己场上1只「超重武者」怪兽为对象才能发动。那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44891812,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c44891812.defcon)
	e1:SetCost(c44891812.defcost)
	e1:SetTarget(c44891812.deftg)
	e1:SetOperation(c44891812.defop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44891812,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c44891812.spcon)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44891812.sptg)
	e2:SetOperation(c44891812.spop)
	c:RegisterEffect(e2)
end
-- 效果作用：判断自己墓地是否存在魔法·陷阱卡
function c44891812.defcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回值为0表示自己墓地没有魔法·陷阱卡
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL+TYPE_TRAP)==0
end
-- 效果作用：将此卡从手牌丢弃作为费用
function c44891812.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果作用：定义过滤函数，筛选表侧表示的「超重武者」怪兽且守备力不为0
function c44891812.deffilter(c)
	-- 返回值为true表示该怪兽为表侧表示、属于「超重武者」卡组且守备力不为0
	return c:IsFaceup() and c:IsSetCard(0x9a) and aux.nzdef(c)
end
-- 效果作用：获取攻击怪兽和被攻击怪兽，并设置目标选择条件
function c44891812.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and c44891812.deffilter(chkc) and chkc~=e:GetLabelObject() end
	if chk==0 then return a and a:IsDefensePos() and d and d:IsControler(1-tp)
		-- 判断场上是否存在满足条件的「超重武者」怪兽作为目标
		and Duel.IsExistingTarget(c44891812.deffilter,tp,LOCATION_MZONE,0,1,a) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的「超重武者」怪兽作为目标
	Duel.SelectTarget(tp,c44891812.deffilter,tp,LOCATION_MZONE,0,1,1,a)
	e:SetLabelObject(a)
end
-- 效果作用：设置攻击怪兽的守备力在伤害计算时增加目标怪兽的守备力
function c44891812.defop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local ac=e:GetLabelObject()
	if ac:IsRelateToBattle() and ac:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果原文内容：那只进行战斗的自己怪兽的守备力只在那次伤害计算时上升作为对象的怪兽的守备力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		ac:RegisterEffect(e1)
	end
end
-- 效果作用：判断是否为对方怪兽的直接攻击宣言
function c44891812.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次攻击的怪兽
	local at=Duel.GetAttacker()
	-- 返回值为true表示是对方怪兽的直接攻击宣言
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果作用：定义过滤函数，筛选可特殊召唤的「超重武者」怪兽
function c44891812.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置特殊召唤目标选择条件
function c44891812.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and c44891812.spfilter(chkc,e,tp) and chkc~=c end
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c44891812.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「超重武者」怪兽作为目标
	local g=Duel.SelectTarget(tp,c44891812.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置操作信息，用于后续特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：将目标怪兽特殊召唤
function c44891812.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
