--ナイト・ショット
-- 效果：
-- ①：以对方场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡破坏。对方不能对应这张卡的发动把作为对象的卡发动。
function c89882100.initial_effect(c)
	-- ①：以对方场上盖放的1张魔法·陷阱卡为对象才能发动。盖放的那张卡破坏。对方不能对应这张卡的发动把作为对象的卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c89882100.target)
	e1:SetOperation(c89882100.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片处于里侧表示。
function c89882100.filter(c)
	return c:IsFacedown()
end
-- 效果发动时的对象选择与连锁限制处理。
function c89882100.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c89882100.filter(chkc) end
	-- 检查对方魔陷区是否存在可以作为对象的里侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(c89882100.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 给发动效果的玩家发送“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方魔陷区1张里侧表示的卡作为效果的对象并建立联系。
	local g=Duel.SelectTarget(tp,c89882100.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置效果处理信息，包含破坏分类和作为对象的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设定连锁限制，防止对方对应这张卡的发动将作为对象的卡发动。
		Duel.SetChainLimit(c89882100.limit(g:GetFirst()))
	end
end
-- 效果处理：若对象卡片仍为里侧表示且与效果有联系，则将其破坏。
function c89882100.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 连锁限制的条件函数，限制不能发动作为对象的卡片。
function c89882100.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
