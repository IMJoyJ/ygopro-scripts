--メガリス・ポータル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：仪式召唤的怪兽在1回合各有1次不会被战斗破坏。
-- ②：「巨石遗物」怪兽特殊召唤的场合，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡。
function c84504242.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：仪式召唤的怪兽在1回合各有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c84504242.indtg)
	e1:SetValue(c84504242.indct)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：「巨石遗物」怪兽特殊召唤的场合，以自己墓地1只仪式怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84504242,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,84504242)
	e2:SetCondition(c84504242.thcon)
	e2:SetTarget(c84504242.thtg)
	e2:SetOperation(c84504242.thop)
	c:RegisterEffect(e2)
end
-- 过滤出仪式召唤的怪兽作为不会被战斗破坏效果的适用对象
function c84504242.indtg(e,c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 设置因战斗破坏时，一回合有1次不会被破坏
function c84504242.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		return 1
	else return 0 end
end
-- 过滤出场上表侧表示的「巨石遗物」怪兽
function c84504242.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x138)
end
-- 检查特殊召唤成功的怪兽中是否存在「巨石遗物」怪兽，作为效果发动的条件
function c84504242.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c84504242.cfilter,1,nil)
end
-- 过滤出自己墓地可以加入手卡的仪式怪兽
function c84504242.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备，进行取对象检测，选择自己墓地1只仪式怪兽作为对象，并设置回收卡片的操作信息
function c84504242.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84504242.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手卡的仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c84504242.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只仪式怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c84504242.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将选择的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理，获取选中的对象，若其仍符合条件则将其加入手牌
function c84504242.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
