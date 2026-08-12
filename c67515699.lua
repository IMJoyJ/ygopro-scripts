--K9－666号 “Jacks”
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡超量召唤的场合或者对方把手卡·墓地的怪兽的效果发动的场合，把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：有这张卡在作为超量素材中的「K9」超量怪兽得到以下效果。
-- ●对方把手卡·墓地的怪兽的效果发动的回合，这张卡给与对方的战斗伤害变成2倍。
local s,id,o=GetID()
-- 注册卡片初始效果，包括XYZ召唤手续、①效果（超量召唤成功时/对方发动怪兽效果时去除素材破坏场上怪兽）、②效果（作为超量素材时赋予「K9」怪兽战斗伤害翻倍的效果）以及用于记录对方发动效果的自定义计数器。
function s.initial_effect(c)
	-- 添加XYZ召唤手续：5星怪兽×2。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合或者对方把手卡·墓地的怪兽的效果发动的场合，把这张卡1个超量素材取除，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon1)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.descon2)
	c:RegisterEffect(e2)
	-- ②：有这张卡在作为超量素材中的「K9」超量怪兽得到以下效果。●对方把手卡·墓地的怪兽的效果发动的回合，这张卡给与对方的战斗伤害变成2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	-- 设置伤害改变效果的值：使对方受到的战斗伤害变成2倍。
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	e3:SetCondition(s.dmcon)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用于记录玩家在手卡或墓地发动怪兽效果的次数。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数：当发动的效果是手卡或墓地的怪兽效果时返回false，使自定义计数器增加。
function s.chainfilter(re,tp,cid)
	-- 获取触发该连锁的效果发动时的所在位置。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 判定①效果发动条件1：这张卡超量召唤成功。
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 判定①效果发动条件2：对方在手卡或墓地发动了怪兽的效果。
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定触发连锁的玩家是对方，且该效果是手卡或墓地发动的怪兽效果。
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&(LOCATION_GRAVE+LOCATION_HAND))~=0
end
-- ①效果的代偿：把这张卡1个超量素材取除。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动准备：以场上1只怪兽为对象，并注册破坏效果的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_MONSTER) end
	-- 判定场上是否存在可以作为破坏对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息：破坏选中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理：将作为对象的怪兽破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 因效果将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定②效果的生效条件：装备此素材的怪兽是「K9」超量怪兽，且对方在本回合发动过手卡或墓地的怪兽效果。
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSetCard(0x1cb)
		-- 判定对方玩家在本回合中发动过手卡或墓地的怪兽效果的次数大于0。
		and Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0
end
