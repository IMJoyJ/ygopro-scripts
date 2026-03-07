--救護部隊
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在，通常怪兽被战斗破坏时才能发动。这张卡变成通常怪兽（战士族·地·3星·攻1200/守400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c33622465.initial_effect(c)
	-- ①：以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33622465.target)
	e1:SetOperation(c33622465.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，通常怪兽被战斗破坏时才能发动。这张卡变成通常怪兽（战士族·地·3星·攻1200/守400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33622465,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,33622465)
	e2:SetCondition(c33622465.spcon)
	e2:SetTarget(c33622465.sptg)
	e2:SetOperation(c33622465.spop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的通常怪兽（可加入手牌）
function c33622465.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 设置效果目标为己方墓地的通常怪兽
function c33622465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c33622465.filter(chkc) end
	-- 判断是否满足发动条件（己方墓地存在通常怪兽）
	if chk==0 then return Duel.IsExistingTarget(c33622465.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c33622465.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果：将目标怪兽加入手牌
function c33622465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断被战斗破坏的怪兽是否为通常怪兽
function c33622465.cfilter(c)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_NORMAL)~=0
end
-- 判断是否满足发动条件（有通常怪兽被战斗破坏）
function c33622465.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33622465.cfilter,1,nil)
end
-- 设置效果目标为己方墓地的通常怪兽
function c33622465.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤此卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,33622465,0,TYPES_NORMAL_TRAP_MONSTER,1200,400,3,RACE_WARRIOR,ATTRIBUTE_EARTH) end
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果：将此卡特殊召唤
function c33622465.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,33622465,0,TYPES_NORMAL_TRAP_MONSTER,1200,400,3,RACE_WARRIOR,ATTRIBUTE_EARTH) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 特殊召唤此卡到己方场上
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		-- 设置此卡离场时的去向为除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
