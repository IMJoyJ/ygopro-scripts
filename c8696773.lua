--陽炎獣 ヒュドラー
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象，自己不能把炎属性以外的怪兽特殊召唤。此外，这张卡为素材的超量怪兽得到以下效果。
-- ●这次超量召唤成功时，可以从自己墓地选择1只名字带有「阳炎兽」的怪兽在这张卡下面重叠作为超量素材。
function c8696773.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡片效果的对象（过滤函数为对方玩家）
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 自己不能把炎属性以外的怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c8696773.splimit)
	c:RegisterEffect(e2)
	-- 此外，这张卡为素材的超量怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c8696773.effcon)
	e3:SetOperation(c8696773.effop)
	c:RegisterEffect(e3)
end
-- 限制自己不能特殊召唤炎属性以外的怪兽
function c8696773.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_FIRE
end
-- 判定该卡是否作为超量召唤的素材
function c8696773.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 为超量召唤出的怪兽注册获得的效果，若该怪兽不是效果怪兽则为其添加“效果怪兽”类型
function c8696773.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功时，可以从自己墓地选择1只名字带有「阳炎兽」的怪兽在这张卡下面重叠作为超量素材。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(8696773,0))  --"补充素材"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c8696773.matcon)
	e1:SetTarget(c8696773.mattg)
	e1:SetOperation(c8696773.matop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这次超量召唤成功时，可以从自己墓地选择1只名字带有「阳炎兽」的怪兽在这张卡下面重叠作为超量素材。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判定该怪兽是否是通过超量召唤成功特殊召唤的
function c8696773.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤自己墓地中可以作为超量素材的「阳炎兽」怪兽
function c8696773.matfilter(c)
	return c:IsSetCard(0x107d) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 选择墓地中1只「阳炎兽」怪兽作为超量素材的效果的发动准备与目标选择
function c8696773.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8696773.matfilter(chkc) end
	-- 检查自己墓地是否存在可以作为超量素材的「阳炎兽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c8696773.matfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为超量素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择并锁定自己墓地的一只「阳炎兽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8696773.matfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为“有一张卡离开墓地”
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将选择的墓地「阳炎兽」怪兽重叠在当前怪兽下作为超量素材的效果处理
function c8696773.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为超量素材的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在当前怪兽下作为超量素材
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
