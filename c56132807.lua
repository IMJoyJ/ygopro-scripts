--アップル・マジシャン・ガール
-- 效果：
-- ①：1回合1次，这张卡被选择作为攻击对象的场合才能发动。从手卡把1只5星以下的魔法师族怪兽特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
-- ②：这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地最多3只「魔术少女」怪兽为对象才能发动（同名卡最多1张）。那些卡加入手卡。
function c56132807.initial_effect(c)
	-- ①：1回合1次，这张卡被选择作为攻击对象的场合才能发动。从手卡把1只5星以下的魔法师族怪兽特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(c56132807.sptg)
	e1:SetOperation(c56132807.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏的场合，以这张卡以外的自己墓地最多3只「魔术少女」怪兽为对象才能发动（同名卡最多1张）。那些卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c56132807.thcon)
	e2:SetTarget(c56132807.thtg)
	e2:SetOperation(c56132807.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中5星以下的魔法师族怪兽且能特殊召唤
function c56132807.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标检查
function c56132807.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c56132807.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：特殊召唤手卡怪兽，转移攻击对象并使攻击怪兽攻击力减半
function c56132807.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c56132807.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽表侧表示特殊召唤，若特殊召唤成功则继续处理
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前进行攻击的怪兽
		local a=Duel.GetAttacker()
		local ag=a:GetAttackableTarget()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) and ag:IsContains(tc) then
			-- 中断当前效果，使后续处理与特殊召唤不同时进行
			Duel.BreakEffect()
			-- 将攻击对象转移为刚刚特殊召唤的怪兽
			Duel.ChangeAttackTarget(tc)
			-- 攻击怪兽的攻击力变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(a:GetAttack()/2))
			a:RegisterEffect(e1)
		end
	end
end
-- 效果②的发动条件：这张卡被战斗或效果破坏
function c56132807.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：墓地中「魔术少女」怪兽且能加入手卡
function c56132807.thfilter(c)
	return c:IsSetCard(0x20a2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择
function c56132807.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56132807.thfilter(chkc) end
	local c=e:GetHandler()
	-- 检查自己墓地是否存在除自身以外的「魔术少女」怪兽
	if chk==0 then return Duel.IsExistingTarget(c56132807.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 获取墓地中所有可以作为效果对象的「魔术少女」怪兽
	local g=Duel.GetMatchingGroup(c56132807.thfilter,tp,LOCATION_GRAVE,0,c):Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择最多3张卡名不同的「魔术少女」怪兽
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,3)
	-- 将选中的卡片注册为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置连锁的操作信息为将选中的卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,tg:GetCount(),0,0)
end
-- 效果②的处理：将作为对象的墓地怪兽加入手卡并给对方确认
function c56132807.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡片加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
