--オルターガイスト・プークエリ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：把自己场上的「幻变骚灵」怪兽作为「幻变骚灵」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡在墓地存在，「幻变骚灵」连接怪兽在自己场上连接召唤的场合才能发动。这张卡加入手卡。
function c59185998.initial_effect(c)
	-- ①：把自己场上的「幻变骚灵」怪兽作为「幻变骚灵」怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。（这个卡名的①的效果1回合只能使用1次）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,59185998)
	e1:SetValue(c59185998.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，「幻变骚灵」连接怪兽在自己场上连接召唤的场合才能发动。这张卡加入手卡。（②的效果在决斗中只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59185998,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,59185999+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c59185998.thcon)
	e2:SetTarget(c59185998.thtg)
	e2:SetOperation(c59185998.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上的「幻变骚灵」怪兽
function c59185998.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x103) and c:IsControler(tp)
end
-- 过滤手卡中的「幻变骚灵·查询普卡」
function c59185998.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(59185998)
end
-- 判定手卡的这张卡作为连接素材的条件：连接怪兽必须是「幻变骚灵」，且必须以自己场上的「幻变骚灵」怪兽为素材，且不能同时将多张手卡的此卡作为素材
function c59185998.matval(e,lc,mg,c,tp)
	if not lc:IsSetCard(0x103) then return false,nil end
	return true,not mg or mg:IsExists(c59185998.mfilter,1,nil,tp) and not mg:IsExists(c59185998.exmfilter,1,nil)
end
-- 过滤自己场上表侧表示连接召唤成功的「幻变骚灵」连接怪兽
function c59185998.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x103) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判定是否自己场上有「幻变骚灵」连接怪兽连接召唤成功
function c59185998.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c59185998.cfilter,1,nil,tp)
end
-- 判定自身能否加入手卡，并设置回收自身的操作信息
function c59185998.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡加入手卡
function c59185998.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
