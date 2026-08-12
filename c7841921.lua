--疾走の暗黒騎士ガイア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡可以不用解放作召唤。
-- ②：不用解放作召唤的这张卡的原本攻击力变成1900。
-- ③：这张卡被解放的场合才能发动。从卡组把1只「混沌战士」怪兽加入手卡。
function c7841921.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7841921,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c7841921.ntcon)
	c:RegisterEffect(e1)
	-- ②：不用解放作召唤的这张卡的原本攻击力变成1900。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(c7841921.atkop)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被解放的场合才能发动。从卡组把1只「混沌战士」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,7841921)
	e3:SetTarget(c7841921.thtg)
	e3:SetOperation(c7841921.thop)
	c:RegisterEffect(e3)
end
-- 不用解放作召唤的条件过滤函数
function c7841921.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否不需要解放、自身等级是否在5星以上，以及己方怪兽区域是否有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检查这张卡召唤时是否没有使用解放的怪兽（即不用解放作召唤）
function c7841921.atkcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 在召唤时，为这张卡注册原本攻击力变成1900的效果
function c7841921.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：不用解放作召唤的这张卡的原本攻击力变成1900。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetCondition(c7841921.atkcon)
	e1:SetValue(1900)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可加入手牌的「混沌战士」怪兽
function c7841921.thfilter(c)
	return c:IsSetCard(0x10cf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测函数
function c7841921.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「混沌战士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7841921.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数
function c7841921.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的「混沌战士」怪兽
	local g=Duel.SelectMatchingCard(tp,c7841921.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
