--青眼の究極亜竜
-- 效果：
-- 「青眼白龙」＋「青眼白龙」＋「青眼白龙」
-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。已用原本卡名是「青眼亚白龙」的怪兽为素材让这张卡融合召唤的场合，这个效果的对象可以变成2张或者3张。这个效果发动的回合，这张卡不能攻击。
function c43228023.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个编号为89631139的怪兽作为融合素材
	aux.AddFusionProcCodeRep(c,89631139,3,true,true)
	-- ①：场上的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval，用于过滤不会成为对方效果对象的卡
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为aux.indoval，用于过滤不会被对方效果破坏的卡
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。
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
	-- 融合召唤成功时触发的效果，用于标记是否使用了青眼亚白龙作为素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c43228023.matcon)
	e0:SetOperation(c43228023.matop)
	c:RegisterEffect(e0)
	-- 融合素材检查效果，用于判断是否包含青眼亚白龙作为融合素材
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c43228023.valcheck)
	e4:SetLabelObject(e0)
	c:RegisterEffect(e4)
end
-- 支付费用函数，确保此卡在本回合未攻击过，否则不能发动效果
function c43228023.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	-- 使此卡在本回合不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 设置效果目标，选择对方场上1到3张卡作为破坏对象
function c43228023.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	if e:GetHandler():GetFlagEffect(43228023)>0 then ct=3 end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的目标卡组
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，确定破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 执行破坏操作，将目标卡破坏
function c43228023.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将目标卡破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 判断是否为融合召唤且使用了青眼亚白龙作为素材
function c43228023.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 注册标记，表示该卡已使用青眼亚白龙作为融合素材
function c43228023.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(43228023,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 判断卡是否为青眼亚白龙（编号38517737）
function c43228023.spfilter(c)
	return c:IsOriginalCodeRule(38517737)
end
-- 检查融合素材中是否包含青眼亚白龙，若包含则标记为1，否则为0
function c43228023.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(c43228023.spfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
