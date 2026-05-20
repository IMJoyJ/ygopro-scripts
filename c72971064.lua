--LL－アンサンブルー・ロビン
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
-- ②：对方对怪兽的特殊召唤成功的场合，把这张卡1个超量素材取除，以那1只特殊召唤的怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ③：这张卡被对方送去墓地的场合，以这张卡以外的自己墓地1只「抒情歌鸲」怪兽为对象才能发动。那只怪兽加入手卡。
function c72971064.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册超量召唤手续：需要2只以上等级1的怪兽
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c72971064.atkval)
	c:RegisterEffect(e1)
	-- 为单张卡注册合并延迟事件，用于监听怪兽特殊召唤成功的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,72971064,EVENT_SPSUMMON_SUCCESS)
	-- ②：对方对怪兽的特殊召唤成功的场合，把这张卡1个超量素材取除，以那1只特殊召唤的怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72971064,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c72971064.thcon)
	e2:SetCost(c72971064.thcost)
	e2:SetTarget(c72971064.thtg)
	e2:SetOperation(c72971064.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方送去墓地的场合，以这张卡以外的自己墓地1只「抒情歌鸲」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72971064,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c72971064.recon)
	e3:SetTarget(c72971064.retg)
	e3:SetOperation(c72971064.reop)
	c:RegisterEffect(e3)
end
-- 攻击力上升值的求值函数，返回超量素材数量×500
function c72971064.atkval(e,c)
	return c:GetOverlayCount()*500
end
-- 效果②的发动条件：特殊召唤的怪兽中存在对方玩家特殊召唤的怪兽
function c72971064.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 效果②的代价：取除这张卡的1个超量素材
function c72971064.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的过滤条件：属于对方特殊召唤的怪兽且能回到手卡
function c72971064.thfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAbleToHand()
end
-- 效果②的目标选择与准备函数：筛选出对方特殊召唤的怪兽并将其设为效果对象
function c72971064.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c72971064.thfilter,nil,tp)
	-- 效果指向判定（重构连锁时）：目标必须在怪兽区且属于本次特殊召唤的怪兽组
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.IsInGroup(chkc,g) end
	-- 效果发动时的合法性检查：场上是否存在至少1个符合条件的可选对象
	if chk==0 then return Duel.IsExistingTarget(aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 当只有1只符合条件的怪兽时，直接将其设为效果对象
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 玩家选择1只符合条件的怪兽作为效果对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置连锁的操作信息：将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果②的处理函数：将作为对象的怪兽送回持有者手卡
function c72971064.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽送回持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡被对方送去墓地（由对方造成且原本由自己控制）
function c72971064.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果③的过滤条件：自己墓地中除这张卡以外的「抒情歌鸲」怪兽，且能加入手卡
function c72971064.filter2(c)
	return c:IsSetCard(0xf7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果③的目标选择与准备函数：选择自己墓地1只「抒情歌鸲」怪兽为对象
function c72971064.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72971064.filter2(chkc) and chkc~=e:GetHandler() end
	-- 效果发动时的合法性检查：自己墓地是否存在除自身以外的、符合条件的「抒情歌鸲」怪兽
	if chk==0 then return Duel.IsExistingTarget(c72971064.filter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1只符合条件的「抒情歌鸲」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72971064.filter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置连锁的操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的处理函数：将作为对象的「抒情歌鸲」怪兽加入手卡
function c72971064.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
