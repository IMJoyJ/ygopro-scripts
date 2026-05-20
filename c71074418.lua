--ウィッチクラフトゴーレム・アルル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在，自己场上的魔法师族怪兽成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时，以对方场上1张卡或者自己墓地1张「魔女术」魔法卡为对象才能发动。这张卡特殊召唤，那张卡回到持有者手卡。
-- ②：对方准备阶段发动。这张卡回到持有者手卡。
function c71074418.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上的魔法师族怪兽……被选择作为对方怪兽的攻击对象时，以对方场上1张卡或者自己墓地1张「魔女术」魔法卡为对象才能发动。这张卡特殊召唤，那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71074418,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71074418)
	e1:SetCondition(c71074418.atkcon)
	e1:SetTarget(c71074418.target)
	e1:SetOperation(c71074418.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡存在，自己场上的魔法师族怪兽成为对方的效果的对象时……以对方场上1张卡或者自己墓地1张「魔女术」魔法卡为对象才能发动。这张卡特殊召唤，那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71074418,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,71074418)
	e2:SetCondition(c71074418.tgcon)
	e2:SetTarget(c71074418.target)
	e2:SetOperation(c71074418.operation)
	c:RegisterEffect(e2)
	-- ②：对方准备阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71074418,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c71074418.retcon)
	e3:SetTarget(c71074418.rettg)
	e3:SetOperation(c71074418.retop)
	c:RegisterEffect(e3)
end
-- 判定自己场上的魔法师族怪兽是否被选择作为对方怪兽的攻击对象
function c71074418.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	-- 验证攻击怪兽由对方控制，且被攻击怪兽由自己控制、表侧表示存在、是魔法师族
	return Duel.GetAttacker():IsControler(1-tp) and at:IsControler(tp) and at:IsFaceup() and at:IsRace(RACE_SPELLCASTER)
end
-- 过滤出自己场上表侧表示的魔法师族怪兽
function c71074418.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判定对方发动的效果是否以自己场上的魔法师族怪兽为对象
function c71074418.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为效果对象的卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(c71074418.cfilter,1,nil,tp)
end
-- 过滤出可以回到手牌的卡（对方场上的卡，或者自己墓地的「魔女术」魔法卡）
function c71074418.thfilter(c,tp)
	return c:IsAbleToHand() and (c:IsControler(1-tp) and c:IsOnField()
		or c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x128) and c:IsType(TYPE_SPELL))
end
-- 效果①的发动合法性检测，确认自身能否特殊召唤以及是否存在合法的回手牌对象
function c71074418.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c71074418.thfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否有空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在至少1张符合条件的、可以作为回手牌对象的卡
		and Duel.IsExistingTarget(c71074418.thfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1张符合条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c71074418.thfilter,tp,LOCATION_GRAVE,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置连锁信息：包含将选中的卡送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息：包含将手牌中的这张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：特殊召唤自身，并将对象卡送回持有者手牌
function c71074418.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前选择的作为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否仍与效果相关，若成功特殊召唤自身，且对象卡仍与效果相关，则继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 将对象卡送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定：必须是对方的回合
function c71074418.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 验证当前回合玩家不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的靶向与发动合法性检测（必发效果，直接返回true并设置操作信息）
function c71074418.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：包含将自身送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将自身送回持有者手牌
function c71074418.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者的手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
