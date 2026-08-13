--マインフィールド
-- 效果：
-- ①：表侧表示的这张卡从自己场上离开时，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
function c24419823.initial_effect(c)
	-- ①：表侧表示的这张卡从自己场上离开时，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24419823,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c24419823.thcon)
	e2:SetTarget(c24419823.thtg)
	e2:SetOperation(c24419823.thop)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定：本卡在离场之前必须是表侧表示，才满足“表侧表示的这张卡从自己场上离开时”的触发条件。
function c24419823.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数：选择自己墓地中满足“场地魔法卡”且“可以加入手卡”的卡作为对象。
function c24419823.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 发动时的目标选择流程：先检查能否选择符合条件的墓地场地魔法卡，若可以则提示玩家选择1张作为对象，并设置相关操作信息。
function c24419823.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24419823.filter(chkc) end
	-- 发动合法性检查：确认自己墓地是否存在至少1张符合条件的场地魔法卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24419823.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的场地魔法卡，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,c24419823.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将本次效果的处理信息登记为“回手牌”类别，并记录对象卡数量，供连锁判定及后续效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得效果对象，若对象仍与该效果关联，则将其加入手牌，并展示给对方玩家确认。
function c24419823.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回发动时选择的那张墓地场地魔法卡作为处理对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入其持有者的手卡（nil表示加入持有者手卡），因由效果处理而移动。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡，以公开信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
