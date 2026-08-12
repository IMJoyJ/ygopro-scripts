--昇華する魂
-- 效果：
-- 仪式怪兽仪式召唤成功时，可以选择那次仪式召唤解放的自己墓地存在的1只怪兽加入手卡。这个效果1回合只能使用1次。
function c88301833.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 仪式怪兽仪式召唤成功时，可以选择那次仪式召唤解放的自己墓地存在的1只怪兽加入手卡。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88301833,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c88301833.thcon)
	e2:SetTarget(c88301833.thtg)
	e2:SetOperation(c88301833.thop)
	c:RegisterEffect(e2)
end
-- 过滤出仪式召唤成功的怪兽
function c88301833.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检查特殊召唤成功的怪兽中是否存在仪式召唤成功的怪兽，作为效果发动的条件
function c88301833.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88301833.cfilter,1,nil)
end
-- 过滤出存在于自己墓地、因解放而送去墓地、可以加入手卡且可以作为效果对象的怪兽
function c88301833.thfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_RELEASE) and c:IsControler(tp) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- 效果发动的目标选择与检测，获取仪式召唤的素材，并从中选择1只符合条件的墓地怪兽作为对象
function c88301833.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	local mat=tc:GetMaterial()
	if chkc then return mat:IsContains(chkc) and c88301833.thfilter(chkc,e,tp) end
	if chk==0 then return mat:IsExists(c88301833.thfilter,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local g=mat:FilterSelect(tp,c88301833.thfilter,1,1,nil,e,tp)
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理的操作信息，表示该连锁将要把选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理的执行函数，将选中的对象怪兽加入手牌并给对方确认
function c88301833.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
