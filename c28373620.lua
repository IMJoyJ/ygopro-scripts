--神碑の牙ゲーリ
-- 效果：
-- 「神碑」怪兽×2
-- ①：这张卡从额外卡组的特殊召唤成功的场合，以速攻魔法卡以外的自己墓地1张「神碑」魔法卡为对象才能发动。那张卡加入手卡。
-- ②：场上的这张卡不会被效果破坏。
-- ③：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
function c28373620.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：用任意2只「神碑」怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x17f),2,true)
	-- ①：这张卡从额外卡组的特殊召唤成功的场合，以速攻魔法卡以外的自己墓地1张「神碑」魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28373620,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c28373620.thcon)
	e1:SetTarget(c28373620.thtg)
	e1:SetOperation(c28373620.thop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28373620,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c28373620.dstg)
	e3:SetOperation(c28373620.dsop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定：检查这张卡是否是从额外卡组特殊召唤成功。
function c28373620.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 筛选可作为①效果对象的卡：自己墓地的「神碑」魔法卡，且不是速攻魔法卡，并且能够加入手牌。
function c28373620.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x17f) and c:IsAbleToHand() and not c:IsType(TYPE_QUICKPLAY)
end
-- ①效果的目标选择处理：在发动时确认墓地存在符合条件的「神碑」魔法卡，并选择1张作为对象，同时设置回手牌的操作信息。
function c28373620.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28373620.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足条件（「神碑」魔法卡、非速攻、可加入手牌）的卡可供选择。
	if chk==0 then return Duel.IsExistingTarget(c28373620.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家弹出选择卡片提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「神碑」魔法卡作为效果对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c28373620.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将所选择的对象卡加入手牌，并标明数量为1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：获取对象卡，若其仍与该效果关联，则将其加入持有者的手卡。
function c28373620.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡（即之前选择的墓地「神碑」魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去持有者的手卡，完成回收。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③效果的目标选择处理：在发动时确认场上存在可选择的卡，并选择1张作为破坏对象，同时设置破坏的操作信息。
function c28373620.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：确认场上存在至少1张可以被选择为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家弹出选择卡片提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上（双方）选择1张卡作为效果对象，并自动与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：将所选择的对象卡破坏，并标明数量为1，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：获取对象卡，若其仍与该效果关联，则将其破坏。
function c28373620.dsop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡（即之前选择的场上卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
