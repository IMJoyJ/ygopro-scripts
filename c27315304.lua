--ミスト・ウォーム
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤成功的场合，以对方场上最多3张卡为对象发动。那些对方的卡回到持有者手卡。
function c27315304.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整1只（不限条件）＋调整以外的怪兽2只以上，满足这些素材条件才能进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，以对方场上最多3张卡为对象发动。那些对方的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27315304,0))  --"返回手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c27315304.thcon)
	e1:SetTarget(c27315304.thtg)
	e1:SetOperation(c27315304.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡特殊召唤成功时，且该特殊召唤的类型为同调召唤（SUMMON_TYPE_SYNCHRO），才满足①效果的发动条件。
function c27315304.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动时的取对象处理：检查对象是否在场上、是否为对方控制、是否能加入手卡；若满足发动条件，提示玩家从对方场上选择1~3张能加入手卡的卡作为对象，并设置操作信息为“回手牌”效果。
function c27315304.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向当前玩家显示“请选择要返回手牌的卡”的选择提示信息，用于引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让当前玩家从对方场上（怪兽区和魔陷区）选择1~3张满足“能加入手卡”的卡作为效果对象，并自动将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,3,nil)
	-- 设置当前连锁的操作信息：效果分类为“送回手牌”（CATEGORY_TOHAND），处理数量为已选择的目标数量，用于后续时点、相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：从连锁信息中取得发动时选择的对象卡，过滤出仍与该效果有关联的卡，然后将这些卡返回持有者手卡；没有可处理的卡则不做处理。
function c27315304.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录中的“对象卡组”，即发动时通过取对象选择的目标卡片集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后仍与效果关联的卡以效果原因（REASON_EFFECT）送回其持有者手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
