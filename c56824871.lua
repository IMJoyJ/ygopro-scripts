--焔聖騎士－リナルド
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有战士族·炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
-- ②：这张卡特殊召唤成功的场合，从自己墓地的卡以及除外的自己的卡之中以「焰圣骑士-里纳尔多」以外的1只战士族·炎属性怪兽或者1张装备魔法卡为对象才能发动。那张卡加入手卡。
function c56824871.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有战士族·炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56824871+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56824871.sprcon)
	e1:SetOperation(c56824871.sprop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤成功的场合，从自己墓地的卡以及除外的自己的卡之中以「焰圣骑士-里纳尔多」以外的1只战士族·炎属性怪兽或者1张装备魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56824871,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,56824872)
	e2:SetTarget(c56824871.thtg)
	e2:SetOperation(c56824871.thop)
	c:RegisterEffect(e2)
end
c56824871.treat_itself_tuner=true
-- 过滤条件：自己场上表侧表示的战士族·炎属性怪兽。
function c56824871.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 特殊召唤规则的条件判定：自身怪兽区域有空位，且自己场上存在战士族·炎属性怪兽。
function c56824871.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件的战士族·炎属性怪兽。
		and Duel.IsExistingMatchingCard(c56824871.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤规则的操作：在自身特殊召唤成功时，为其添加“当作调整使用”的效果。
function c56824871.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地或除外状态的、「焰圣骑士-里纳尔多」以外的1只战士族·炎属性怪兽或者1张装备魔法卡，且能加入手卡。
function c56824871.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(56824871)) or c:IsType(TYPE_EQUIP)) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择：检查并选择自己墓地或除外状态的1张符合条件的卡作为对象，并设置回收操作信息。
function c56824871.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c56824871.thfilter(chkc) end
	-- 检查自己墓地或除外的卡中是否存在至少1个符合条件的可选择对象。
	if chk==0 then return Duel.IsExistingTarget(c56824871.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 给发动效果的玩家发送“选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地或除外的卡中选择1张符合条件的卡作为效果的对象。
	local g=Duel.SelectTarget(tp,c56824871.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：获取选中的对象，若该卡仍符合条件，则将其加入手牌。
function c56824871.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
