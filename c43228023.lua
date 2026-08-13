--青眼の究極亜竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。这个效果发动的回合，这张卡不能攻击。
function c43228023.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以3只卡号89631139（「青眼白龙」）为素材进行融合召唤，并允许使用代用素材。
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
	-- ①：场上的这张卡不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设定『不会成为对方效果对象』的判定条件：只免疫对方玩家的效果。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设定『不会被对方效果破坏』的判定条件：只免疫对方玩家的效果。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。这个效果发动的回合，这张卡不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43228023,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c43228023.descost)
	e3:SetTarget(c43228023.destg)
	e3:SetOperation(c43228023.desop)
	c:RegisterEffect(e3)
	-- 已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c43228023.matcon)
	e0:SetOperation(c43228023.matop)
	c:RegisterEffect(e0)
	-- 已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c43228023.valcheck)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
-- 作为发动代价：检查这张卡本回合未进行过攻击宣言；通过后给自己附加一个不能被无效的、持续到回合结束的『不能攻击』誓约效果。
function c43228023.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ②效果的对象选择处理：选择对方场上的卡为对象，默认1张；若这张卡有以「青眼亚白龙」为素材融合召唤的标记，则可以选择2~3张；随后登记要破坏这些卡的操作信息。
function c43228023.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动前检查：对方场上是否存在至少1张可成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	if e:GetHandler():GetFlagEffect(43228023)>0 then ct=3 end
	-- 显示选择提示消息，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1~ct张卡作为效果对象（ct根据是否有亚白龙素材标记决定为1或3），并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁处理信息：本次效果将破坏所选择的对象卡，使其他卡能够响应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果处理：取得该连锁中仍与效果关联的对象卡，将其破坏。
function c43228023.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取这个效果选择的卡，并过滤掉因离场等原因与效果失去关联的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以『效果』为原因破坏这些对象卡。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判定条件：这张卡以融合召唤方式特殊召唤成功，且素材检查标记为1（表示使用了「青眼亚白龙」作为融合素材）。
function c43228023.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 融合召唤成功时给这张卡放置43228023标记，表示它以「青眼亚白龙」为素材进行过融合召唤；该标记使②效果的可选对象数量变为2~3张。
function c43228023.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(43228023,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤函数：判断卡的原本卡号是否为38517737（「青眼亚白龙」），用于检查融合素材中是否含有该卡。
function c43228023.spfilter(c)
	return c:IsOriginalCodeRule(38517737)
end
-- 素材检查：读取实际融合素材，若其中存在原本卡名为「青眼亚白龙」的怪兽，则将e0标记设为1，否则设为0，供特殊召唤成功时判断是否满足多选对象条件。
function c43228023.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c43228023.spfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
