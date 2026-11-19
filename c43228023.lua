--青眼の究極亜竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。这个效果发动的回合，这张卡不能攻击。
function c43228023.initial_effect(c)
	-- 记录这张卡的卡文上记载了「青眼亚白龙」的卡名。
	aux.AddCodeList(c,38517737)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以3只「青眼白龙」作为融合素材。
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
	-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置这张卡不会成为对方的卡的效果对象（仅己方效果可选中）。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置这张卡不会被对方的卡的效果破坏。
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
	-- 已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c43228023.matcon)
	e0:SetOperation(c43228023.matop)
	c:RegisterEffect(e0)
	-- 已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c43228023.valcheck)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
-- ②效果的代价处理函数：确认这张卡本回合尚未攻击宣言，并赋予其直到回合结束时不能攻击的誓约限制。
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
-- ②效果的对象选择与目标处理函数：若带有融合素材标记则可选1～3张、否则选1张对方场上的卡作为对象，并申报破坏操作信息。
function c43228023.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动可行性检测：检查对方场上是否存在至少1张可成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	if e:GetHandler():GetFlagEffect(43228023)>0 then ct=3 end
	-- 向自己发送选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张（若使用了「青眼亚白龙」融合召唤则最多3张）卡作为对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：预计破坏所选数量的对方场上卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ②效果的效果处理函数：过滤保留仍与本效果有联系的对象卡并将其破坏。
function c43228023.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡片组，并过滤保留仍与本效果有联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍与本效果有联系的对象卡以效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 素材标记的触发条件判定：检查这张卡是否为融合召唤成功且在素材检查中被标记为满足条件。
function c43228023.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 素材标记的处理函数：为这张卡注册标识效果，记录其已使用原本卡名为「青眼亚白龙」的怪兽作为融合素材。
function c43228023.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(43228023,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 过滤函数：判断融合素材的原本卡名规则上是否为「青眼亚白龙」。
function c43228023.spfilter(c)
	return c:IsOriginalCodeRule(38517737)
end
-- 融合素材检查函数：检测融合素材中是否存在原本卡名为「青眼亚白龙」的怪兽，并将判断结果写入关联的持续效果Label中。
function c43228023.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c43228023.spfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
